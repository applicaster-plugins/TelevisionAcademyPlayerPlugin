//
//  BulbView.swift
//  LightApp
//
//  Created by Afanasiev, Anatolii on 21/01/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import UIKit
import BitmovinPlayer

class PlayerView: UIView {

  // player
  var bitmovinPlayer: BitmovinPlayer?
  var bitmovinPlayerView: BMPBitmovinPlayerView?

  // skylark API
  var baseSkylarkUrl: NSString? = nil
  var lastTrackDate: Date? = nil
  var task: URLSessionDataTask? = nil
  let trackTimeStep: Double = 5.0

  // react native bridge
  @objc var showSettingsEvent: RCTDirectEventBlock?

  @objc var playableItem: NSDictionary? {
    didSet {

      guard let config = playableItem else { return }
      
      guard let content = config[BridgeConstants.content.rawValue] as? NSDictionary,
        let sourceId = config[BridgeConstants.id.rawValue] as? NSString,
        let videoSrc = content[BridgeConstants.source.rawValue] as? NSString else {
          return
      }

      var elapsedTime: Double? = nil

      if let extensions = config[BridgeConstants.extensions.rawValue] as? NSDictionary,
        let elapsedTimeVar = extensions[BridgeConstants.elapsedTime.rawValue] as? Double {
        elapsedTime = elapsedTimeVar
      }

      startPlayer(videoSrc as String, elapsedTime: elapsedTime, identifier: sourceId as String)
    }
  }

  @objc var onKeyChanged: NSDictionary? {
    didSet {

      guard let config = onKeyChanged,
        let keyCode = config[BridgeConstants.keyCode.rawValue] as? Int else {
          return
      }

      self.performRemoteControlKey(key: keyCode)
    }

  }
  
  @objc var pluginConfiguration: NSDictionary? {
    didSet {

      guard let config = pluginConfiguration,
        let baseSkylarkUrl = config[BridgeConstants.baseSkylarkUrl.rawValue] as? NSString else {
          return
      }

      self.baseSkylarkUrl = baseSkylarkUrl

      guard let testVideoSrc = config[BridgeConstants.testVideoSrc.rawValue] as? NSString else {
        return
      }

      self.startPlayer(testVideoSrc as String, elapsedTime: nil, identifier: "test")
    }
  }
  
  @objc var onSettingSelected: NSDictionary? {
    didSet {

      guard let config = onSettingSelected,
        let typeVar = config[BridgeConstants.type.rawValue] as? NSString,
        let value = config[BridgeConstants.id.rawValue] as? NSString,
        let type = BridgeConstants(rawValue: typeVar as String) else {
          return
      }

      if type == BridgeConstants.AUDIO_TRACK_TYPE {
        self.setAudioQuality(audioQuality: value as String)
      } else if type == BridgeConstants.VIDEO_QUALITY_TYPE {
        self.setVideoQuality(videoQuality: value as String)
      } else if type == BridgeConstants.LANGUAGE_SUBTITLE_TYPE {
        self.setSubtitle(subtitle: value as String)
      }

    }
  }
}

//MARK:- Player

extension PlayerView {

  private func startPlayer(_ url: String, elapsedTime: Double?, identifier: String) {

    let sourceItem = PlayableSourceItem(sourceItemUrl: URL(string: url)!, elapsedTime: elapsedTime, identifier: identifier)
    let config = PlayerConfiguration()
    config.playbackConfiguration.isAutoplayEnabled = true
    config.sourceItem = sourceItem

    let player = BitmovinPlayer(configuration: config)
    player.add(listener: self)

    DispatchQueue.main.async {
      let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
      playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      playerView.frame = self.bounds
      playerView.add(listener: self)

      self.addSubview(playerView)
      self.bringSubviewToFront(playerView)

      self.bitmovinPlayer = player
      self.bitmovinPlayerView = playerView
    }
  }


  private func setAudioQuality(audioQuality: String) {

    guard let player = self.bitmovinPlayer else {
      return
    }

    DispatchQueue.main.async {
      player.setAudio(trackIdentifier: audioQuality)
    }
  }
  
  private func setVideoQuality(videoQuality: String) {
//    self.bitmovinPlayer.maxSelectableBitrate =
  }
  
  private func setSubtitle(subtitle: String) {

    guard let player = self.bitmovinPlayer else {
      return
    }

    DispatchQueue.main.async {
      player.setSubtitle(trackIdentifier: subtitle)
    }

  }

}
