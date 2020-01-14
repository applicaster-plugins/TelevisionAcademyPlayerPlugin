//
//  ZPPlayable+Utils.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 13.01.2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappPlugins

extension ZPPlayable {

    func toString() -> String {
        return """
        Name: \(String(describing: playableName()))
        Description: \(String(describing: playableDescription()))
        VideoURLPath: \(String(describing: contentVideoURLPath()))
        isLive: \(isLive())
        isFree: \(isFree)
        identifier: \(String(describing: identifier)))
        extensions: \(String(describing: extensionsDictionary))
        analytics: \(String(describing: analyticsParams()))
        """
    }

    // MARK: - Analytics

    var event: AnalyticsEvent {
        return isLive() ? .live : .vod
    }

    var additionalAnalyticsParams: [String: Any] {
        var params: [String: Any] = [AnalyticsKeys.isFree.rawValue: isFree ? "Free" : "Paid",
                                     AnalyticsKeys.itemID.rawValue: identifier ?? "",
                                     AnalyticsKeys.itemName.rawValue: playableName() ?? ""]
        if isLive() == false {
            if let duration = playbackDuration {
                params[AnalyticsKeys.itemDuration.rawValue] = String.create(fromInterval: duration)
            }
            params[VodType.key] = VodType.atom.rawValue
        }

        return params
    }

    var isFree: Bool {
        guard let value = extensionsDictionary?["free"] as? Bool else {
            return true
        }
        return value
    }
}
