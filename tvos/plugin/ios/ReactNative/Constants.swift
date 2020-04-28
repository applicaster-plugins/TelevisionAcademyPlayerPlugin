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
    case elapsedTime = "playhead_position"
    case contentGroup = "content_group"
    case baseSkylarkUrl = "baseSkylarkUrl"
    case testVideoSrc = "testVideoSrc"
    case type = "type"
    case keyCode = "keyCode"
    case bitmovinAnalyticLicenseKey = "bitmovinAnalyticLicenseKey"
    case bitmovinPlayerLicenseKey = "bitmovinPlayerLicenseKey"
    case heartbeatInterval = "heartbeatInterval"
}

enum CommonConstants: Int {
    case miliseconds = 1000
    case SEEKING_OFFSET = 10
    case TRACK_TIME_INTERVAL = 5
    case DEFAULT_HEARTBEAT_INTERVAL = 5000
}
