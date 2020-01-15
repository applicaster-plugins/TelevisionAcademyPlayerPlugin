//
//  AnalyticParamsBuilder.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 15.01.2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
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

    public var isLive = false {
        didSet {
            let isLive = self.isLive ? "Live" : "VOD"
            parameters[AnalyticsKeys.videoType.rawValue] = isLive
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

    public var durationInVideo = 0.0 {
        didSet {
            parameters[AnalyticsKeys.durationInVideo.rawValue] = String.create(fromInterval: durationInVideo)
        }
    }

    public var originalView: PlayerScreenMode = .fullscreen {
        didSet {
            parameters[AnalyticsKeys.originalView.rawValue] = stringValue(from: originalView)
        }
    }

    public var newView: PlayerScreenMode = .fullscreen {
        didSet {
            parameters[AnalyticsKeys.newView.rawValue] = stringValue(from: newView)
        }
    }

    public var viewSwitchCounter = 0 {
        didSet {
            parameters[AnalyticsKeys.switchInstance.rawValue] = "\(viewSwitchCounter)"
        }
    }

    public var seekDirection = "" {
        didSet {
            parameters[AnalyticsKeys.seekDirection.rawValue] = seekDirection
        }
    }

    public var captionsPreviousState = false {
        didSet {
            let state = captionsPreviousState == true ? "On" : "Off"
            parameters[AnalyticsKeys.captionsPreviousState.rawValue] = state
        }
    }

    private(set) var parameters: [String: String] = [:]

    // MARK: - Private methods

    private func stringValue(from screenMode: PlayerScreenMode) -> String {
        switch screenMode {
        case .fullscreen:
            return "Full Screen"
        case .inline:
            return "Inline"
        }
    }
}
