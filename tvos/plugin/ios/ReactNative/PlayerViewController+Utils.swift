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

    func trackTime(force: Bool, newTime: Double? = nil) {

        guard let playerVar = self.bitmovinPlayer else {
            return
        }

        let lastTrack: Double = Date().timeIntervalSince(self.lastTrackDate)

        let needUpdate = lastTrack > 5.0

        if !force && !needUpdate {
            return
        }

        guard let item = self.currentPlayable,
            let baseSkylarkUrlVar = self.baseSkylarkUrl else {
                return
        }

        guard var token = FacadeConnector.connector?.storage?.localStorageValue(for: "token", namespace: "login")  else {
            return
        }
        
        //Temprorary fix for incorrect store into the local storage.
        if (token.hasPrefix("\"")) {
            token = String(token.dropFirst(1))
        }
        if (token.hasSuffix("\"")) {
            token = String(token.dropLast(1))
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
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
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
