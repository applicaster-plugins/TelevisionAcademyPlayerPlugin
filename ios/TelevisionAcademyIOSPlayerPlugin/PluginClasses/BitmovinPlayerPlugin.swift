//
//  BitmovinPlayerPlugin.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 27.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappPlugins

public class BitmovinPlayerPlugin: NSObject, ZPPlayerProtocol, ZPPluggableScreenProtocol {

    public func pluggablePlayerViewController() -> UIViewController? {
        fatalError()
    }

    public func pluggablePlayerIsPlaying() -> Bool {
        fatalError()
    }

    public func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        fatalError()
    }

    public func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        fatalError()
    }

    public func pluggablePlayerRemoveInline() {
        fatalError()
    }

    public func pluggablePlayerPause() {
        fatalError()
    }

    public func pluggablePlayerStop() {
        fatalError()
    }

    public func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        fatalError()
    }

    public var screenPluginDelegate: ZPPlugableScreenDelegate?

    public required init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        fatalError()

    }
}
