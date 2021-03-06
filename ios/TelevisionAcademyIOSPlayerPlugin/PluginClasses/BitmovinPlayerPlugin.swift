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

    private var playerViewController: PlayerViewController!
    private var analytics: AnalyticsAdapterProtocol

    @objc weak public var screenPluginDelegate: ZPPlugableScreenDelegate?
    private var pluginModel: ZPPluginModel?
    private var screenModel: ZLScreenModel?
    private var dataSourceModel: NSObject?

    init(analytics: AnalyticsAdapterProtocol = AnalyticsAdapter()) {
        self.analytics = analytics
        super.init()
    }

    required public init?(pluginModel: ZPPluginModel, screenModel: ZLScreenModel, dataSourceModel: NSObject?) {
        self.pluginModel = pluginModel
        self.screenModel = screenModel
        self.dataSourceModel = dataSourceModel
        self.analytics = AnalyticsAdapter()
    }
}

//MARK:- ZPPlayerProtocol

extension BitmovinPlayerPlugin: ZPPlayerProtocol {

      static public func pluggablePlayerType() -> ZappPlugins.ZPPlayerType {
            return .undefined
      }

    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary?) -> ZPPlayerProtocol? {

        var videos: [ZPPlayable] = items ?? [ZPPlayable]()

        if let configurationJSONVar = configurationJSON,
            let testUrl = configurationJSONVar["test_video_url"] as? String,
            testUrl.isEmpty == false {
            videos.removeAll()
            videos.append(ZPPlayableItem.createTest(for: testUrl))
        }
        
        let dspBaseURL = configurationJSON?["dsp_base_url"] as? String ?? ""
        let tvaApiBaseURL = configurationJSON?["api_base_url"] as? String ?? ""
        let dspParamemers = configurationJSON?["dsp_parameters_url"] as? String ?? ""
        
        let feedParser = FeedParser(video: videos.first!,
                                    dspBaseURL: dspBaseURL,
                                    tvaApiBaseURL: tvaApiBaseURL,
                                    dspParameters: dspParamemers)
        
        let parsedVideos = feedParser.parseVideos()

        let playerViewController = PlayerViewController(with: parsedVideos, configurationJSON: configurationJSON)

        let instance = BitmovinPlayerPlugin()
        playerViewController.analyticEventDelegate = instance
        instance.playerViewController = playerViewController

        return instance
    }

    public func pluggablePlayerViewController() -> UIViewController? {
        return self.playerViewController
    }

    public func pluggablePlayerIsPlaying() -> Bool {
        guard let playerVar = self.playerViewController.player else { return false }
        return playerVar.isPlaying
    }

    public func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        presentPlayerFullScreen(rootViewController, configuration: configuration) {
        }
    }

    public func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?, completion: (() -> Void)?) {

        guard let playerViewController = self.playerViewController,
            let topmostViewController = rootViewController.topmostModal() else {
                return
        }

        playerViewController.modalPresentationStyle = .fullScreen

        topmostViewController.present(playerViewController, animated: configuration?.animated ?? true, completion: completion)

        // analytics
        analytics.screenMode = .fullscreen

        if let item = playerViewController.getCurrentPlayable,
            let progress = playerViewController.getPlaybackState {
            analytics.complete(item: item, progress: progress)
        }
    }

    public func pluggablePlayerAddInline(_ rootViewController: UIViewController, container: UIView) {

        guard let playerViewController = self.playerViewController else { return }

        playerViewController.setInlineView(rootViewController: rootViewController, container: container)
        analytics.screenMode = .inline
    }

    public func pluggablePlayerRemoveInline() {

        guard let playerViewController = self.playerViewController else {
            return
        }

        playerViewController.setFullscreenView()

        // analytics
        if let item = playerViewController.getCurrentPlayable,
            let progress = playerViewController.getPlaybackState {
            analytics.complete(item: item, progress: progress)
        }
    }

    public func pluggablePlayerPause() {
        self.playerViewController.pause()
    }

    public func pluggablePlayerStop() {
        self.playerViewController.stop()
    }

    public func pluggablePlayerPlay(_ configuration: ZPPlayerConfiguration?) {
        self.playerViewController.play()
    }
}

//MARK:- PlaybackAnalyticEventsDelegate

extension BitmovinPlayerPlugin: PlaybackAnalyticEventsDelegate {
    func eventOccurred(_ event: AnalyticsEvent, params: [AnyHashable : Any], timed: Bool) {
        analytics.track(event: event, withParameters: params, timed: timed)
    }
}
