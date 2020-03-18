//
//  AnalyticParamsBuilder.swift
//  BitmovinRNPlayer
//
//  Created by Vladyslav Sumtsov on 3/17/20.
//

import Foundation

class AnalyticParamsBuilder {
    
    public var duration = 0.0 {
        didSet {
            parameters[AnalyticsKeys.itemDuration.rawValue] = String.create(fromInterval: duration)
        }
    }

    public var progress = 0.0 {
        didSet {
            parameters[AnalyticsKeys.timecode.rawValue] = String.create(fromInterval: progress)
        }
    }

    public var timecodeFrom = 0.0 {
        didSet {
            parameters[AnalyticsKeys.timecodeFrom.rawValue] = String.create(fromInterval: timecodeFrom)
        }
    }
    public var timecodeTo = 0.0 {
        didSet {
            parameters[AnalyticsKeys.timecodeTo.rawValue] = String.create(fromInterval: timecodeTo)
        }
    }

    public var seekDirection = "" {
        didSet {
            parameters[AnalyticsKeys.seekDirection.rawValue] = seekDirection
        }
    }

    private(set) var parameters: [String: Any] = [:]
}

enum AnalyticsEvent: String {
    case vod = "Play VOD Item"
    case live = "Play Live Stream"
    case pause = "Pause"
    case seek = "Seek"
    case rewind = "Tap Rewind"
}

enum AnalyticsKeys: String {
    case itemName = "Item Name"
    case itemDuration = "Item Duration"
    case timecode = "Timecode"
    case timecodeFrom = "Timecode From"
    case timecodeTo = "Timecode To"
    case seekDirection = "Seek Direction"
}
