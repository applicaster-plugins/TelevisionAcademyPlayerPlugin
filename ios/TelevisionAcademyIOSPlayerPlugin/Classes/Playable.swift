//
//  Playable.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 29.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappPlugins

class Playable: NSObject, ZPPlayable {

    public var name = ""
    public var playDescription = ""
    public var videoURL = ""
    public var overlayURL = ""
    public var live = false
    public var free = true
    public var publicPageURL = ""

    func playableName() -> String! {
        return name
    }

    func playableDescription() -> String! {
        return playDescription
    }

    func contentVideoURLPath() -> String! {
        return videoURL
    }

    func overlayURLPath() -> String! {
        return overlayURL
    }

    func isLive() -> Bool {
        return live
    }

    func isFree() -> Bool {
        return free
    }

    func publicPageURLPath() -> String! {
        return publicPageURL
    }

    func analyticsParams() -> [AnyHashable : Any]! {
        return [:]
    }

    func assetUrl() -> AVURLAsset? {
        return nil
    }

    var identifier: NSString?

    var extensionsDictionary: NSDictionary?
}
