//
//  PlayerBridgeView+Utils.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 23.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import BitmovinPlayer
import ZappPlugins
import ZappCore

extension PlayerViewController {

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
            let baseSkylarkUrlVar = self.baseSkylarkUrl else {
                return
        }

        guard let token = FacadeConnector.connector?.storage?.localStorageValue(for: "token", namespace: "login")  else {
            return
        }

        let duration = Int(playerVar.duration)
        let currentTime = Int(newTime ?? (playerVar.currentTime))
        let contentGroup = currentPlayable?.contentGroup ?? ""
    
        let jsonBody : [String:Any] = [
            "content_length": duration,
            "playhead_position": currentTime,
            "content_group": contentGroup
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        let putApi = (baseSkylarkUrlVar as String) + "/watchlist/" + item.identifier

        let url = URL(string: putApi)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer " + token, forHTTPHeaderField: "user_token")
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
}
