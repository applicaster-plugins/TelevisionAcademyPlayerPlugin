//
//  PlayerBridgeView+Utils.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 23.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import BitmovinPlayer
//import ApplicasterSDK

extension PlayerView {

  var currentPlayable: PlayableSourceItem? {
    return self.bitmovinPlayer?.config.sourceItem as? PlayableSourceItem
  }

  func trackTime(force: Bool, newTime: Double? = nil) {

    guard let playerVar = self.bitmovinPlayer else {
      return
    }

    var lastTrack: Double = 0.0

    if let last = self.lastTrackDate {
      lastTrack = Date().timeIntervalSince(last)
    }

    let needUpdate = lastTrack > 5.0

    if !force && !needUpdate {
      return
    }

    guard let item = self.currentPlayable,
      let baseSkylarkUrlVar = self.baseSkylarkUrl else { return }

    let duration = round(playerVar.duration)
    let currentTime = newTime ?? round(playerVar.currentTime)

    let jsonBody = [
      "content_length": duration,
      "playhead_position": currentTime
    ]

//    if let loginProvider = ZPLoginManager.sharedInstance.create() as? ZPLoginProviderUserDataProtocol {
//      loginProvider.getUserToken()
//    }

//    ZPBaseLoginProvider


    let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
    let putApi = (baseSkylarkUrlVar as String) + "/watchlist/" + item.identifier

    let url = URL(string: putApi)!
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.addValue("Bearer " + "LoginManager.getLoginPlugin().token", forHTTPHeaderField: "user_token")
    request.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print("error: \(error)")
      } else {
        if let response = response as? HTTPURLResponse {
          print("statusCode: \(response.statusCode)")
        }
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
          print("data: \(dataString)")
        }
      }
    }
    task.resume()

    self.task = task
    self.lastTrackDate = Date()
  }


  func uploadVideoInfo() {

    guard let player = self.bitmovinPlayer else {
      return
    }

    var list: [[String: Any]] = [[String: Any]]()

    // Audio

    if player.availableAudio.count > 1 {

      let available = player.availableAudio.map { [
        "title": $0.label,
        "type": BridgeConstants.AUDIO_TRACK_TYPE.rawValue,
        "id": $0.identifier
        ]}

      let map = [
        "title": "Audio Track:",
        "subtitle": player.audio?.label ?? "auto",
        "selectedId": player.audio?.identifier ?? "some_identifier",
        "type": BridgeConstants.AUDIO_TRACK_TYPE.rawValue,
        "available": available
        ] as [String : Any]

      list.append(map)
    }

    // Video
    if player.availableVideoQualities.count > 1 {

      let available = player.availableVideoQualities.map { [
        "title": $0.label,
        "type": BridgeConstants.VIDEO_QUALITY_TYPE.rawValue,
        "id": $0.identifier
        ]}

      let selectedId = player.videoQuality?.identifier ?? "some_identifier"

      let map: [String: Any] = [
        "title": "Video Quality:",
        "subtitle": "selectedVideoQuality" ,
        "selectedId": selectedId,
        "type": BridgeConstants.VIDEO_QUALITY_TYPE.rawValue,
        "available": available
      ]

      list.append(map)
    }


    // Subtitles
    if player.availableSubtitles.count > 1 {

      let available = player.availableSubtitles.map { [
        "title": $0.label,
        "type": BridgeConstants.LANGUAGE_SUBTITLE_TYPE.rawValue,
        "id": $0.identifier
        ]}

      let map = [
        "title": "Subtitles:",
        "subtitle": player.subtitle.label ,
        "selectedId": player.subtitle.label,
        "type": BridgeConstants.LANGUAGE_SUBTITLE_TYPE.rawValue,
        "available": available
        ] as [String : Any]

      list.append(map)
    }

    // Push to ReactNative

    guard list.isEmpty == false else {
      return
    }

    guard let jsonData = try? JSONSerialization.data(withJSONObject: list, options: .prettyPrinted),
      let json = String.init(data: jsonData, encoding: .utf8) else {
        return
    }

    showSettingsEvent!(["showSettingsEvent": json])
  }

  func performRemoteControlKey(key: Int) {

    guard let key = UIPress.PressType.init(rawValue: key) else { return }

    switch key {
    case .select, .playPause:
      togglePlay()

    case .menu:
      uploadVideoInfo()

    case .leftArrow:
      seekBackward()

    case .rightArrow:
      seekForward()

    default:
      break
    }
  }

  private func togglePlay() {

    guard let player = self.bitmovinPlayer  else {
      return
    }

    if player.isPlaying {
      player.pause()
      return
    }

    player.play()
    trackTime(force: true)
  }

  private func seekForward() {

    guard let player = self.bitmovinPlayer  else {
      return
    }

    let newTime = player.currentTime + TimeInterval(CommonConstants.SEEKING_OFFSET.rawValue)
    player.seek(time: newTime)
    trackTime(force: true, newTime: newTime)
  }

  private func seekBackward() {

    guard let player = self.bitmovinPlayer  else {
      return
    }

    let newTime = player.currentTime - TimeInterval(CommonConstants.SEEKING_OFFSET.rawValue)
    player.seek(time: newTime)
    trackTime(force: true, newTime: newTime)
  }

}
