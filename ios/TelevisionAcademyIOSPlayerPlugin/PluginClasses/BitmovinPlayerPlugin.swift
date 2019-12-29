//
//  BitmovinPlayerPlugin.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 27.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappPlugins

public class BitmovinPlayerPlugin: NSObject, ZPPluggableScreenProtocol {

    var playerViewController: PlayerViewController?

    @objc weak public var screenPluginDelegate: ZPPlugableScreenDelegate?
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?

    // MARK: - Lifecycle

    override init() {
        super.init()
    }

    required public init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
    }

}

//MARK:- ZPPlayerProtocol

extension BitmovinPlayerPlugin: ZPPlayerProtocol {

    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {

        guard let videos = items else { return nil }

        let vc = PlayerViewController(with: videos, configurationJSON: configurationJSON)
        let instance = BitmovinPlayerPlugin()
        instance.playerViewController = vc

        return instance
    }

    public func pluggablePlayerViewController() -> UIViewController? {
        return self.playerViewController
    }

    public func pluggablePlayerIsPlaying() -> Bool {
        return self.playerViewController!.player?.isPlaying ?? false
    }

    public func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        presentPlayerFullScreen(rootViewController, configuration: configuration) {
            self.playerViewController?.player?.play()
        }
    }

    public func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {
//        guard let playerViewController = self.playerViewController,
//            let topmostViewController = rootViewController.topmostModal(),
//            let currentItem = playerViewController.player.currentItem  else {
//            return
//        }
//
//        let animated: Bool = configuration?.animated ?? true
//        playerViewController.builder.mode = .fullscreen
//        playerViewController.setupPlayer()
//        playerViewController.delegate = self.adAnalytics
//        playerViewController.onDismiss = { [weak self] in
//            self?.analytics.complete(item: playerViewController.player.currentItem!,
//                                     progress: playerViewController.player.playbackState)
//        }
//        playerViewController.analyticEventDelegate = self
//
//        analytics.screenMode = .fullscreen
//        topmostViewController.present(playerViewController, animated: animated, completion: completion)
    }

    public func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {
        guard let playerViewController = self.playerViewController else { return }

//             playerViewController.builder.mode = .inline
//
//             rootViewController.addChildViewController(playerViewController, to: container)
//             playerViewController.view.matchParent()
//             playerViewController.setupPlayer()
//             playerViewController.delegate = self.adAnalytics
//             playerViewController.analyticEventDelegate = self
//             analytics.screenMode = .inline
    }

    public func pluggablePlayerRemoveInline() {
//        if let item = self.playerViewController?.player.currentItem,
//            let progress = self.playerViewController?.player.playbackState {
//            analytics.complete(item: item,
//                               progress: progress)
//        }
//
//        let container = self.playerViewController?.view.superview
//        container?.removeFromSuperview()
    }

    public func pluggablePlayerPause() {
        self.playerViewController?.player?.pause()

    }

    public func pluggablePlayerStop() {
//        self.playerViewController?.player?.stop()
    }

    public func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        self.playerViewController?.player?.play()
    }
}
