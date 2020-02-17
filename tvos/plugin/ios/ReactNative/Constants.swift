//
//  Constants.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 23.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

enum BridgeConstants: String {
    case content = "content"
    case id = "id"
    case source = "src"
    case extensions = "extensions"
    case elapsedTime = "elapsed_time"
    case baseSkylarkUrl = "baseSkylarkUrl"
    case testVideoSrc = "testVideoSrc"
    case type = "type"
    case keyCode = "keyCode"
}

enum CommonConstants: Int {
    case miliseconds = 1000
    case SEEKING_OFFSET = 10
    case TRACK_TIME_INTERVAL = 5
}
