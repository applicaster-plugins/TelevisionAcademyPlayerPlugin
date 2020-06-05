 //
 //  PlayerViewController.swift
 //  BrightcovePlayerTVOS
 //
 //  Created by Egor Brel on 8/15/19.
 //

 import Foundation
 import UIKit
 import BitmovinPlayer
 import BitmovinAnalyticsCollector

 class PlayerViewController: UIViewController {
    weak var eventsResponderDelegate: PlayerEventsResponder?
    weak var bitmovinPlayer: BitmovinPlayer?
    weak private var bitmovinPlayerView: BMPBitmovinPlayerView?
    weak private var analyticCollector: BitmovinAnalytics?

    var playableItem: NSDictionary? {
        willSet(newPlayableItem) {
            if (self.playableItem != nil) {
                initialisePlayer(playableItem: newPlayableItem)
            }
        }
    }
    var baseSkylarkUrl: NSString?
    var testVideoSrc: NSString?
    var analyticKey: NSString?
    var playerKey: NSString?
    var heartbeatInterval: Int = 5000

    var lastTrackDate: Date = Date(timeIntervalSince1970: 0)
    weak var task: URLSessionDataTask? = nil
    let trackTimeStep: Double = 5.0
    var skipSeekTrack: Bool = false

    func clean() {
        bitmovinPlayer?.destroy()
        bitmovinPlayer = nil
        bitmovinPlayerView = nil
        analyticCollector?.detachPlayer()
        analyticCollector = nil
        task = nil
    }
    
    deinit {
        clean()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialisePlayer(playableItem: playableItem)
    }

    private func initialisePlayer(playableItem: NSDictionary?) {
        guard let config = playableItem else { return }

        guard let content = config[BridgeConstants.content.rawValue] as? NSDictionary,
            let sourceId = config[BridgeConstants.id.rawValue] as? NSString,
            let videoSrc = content[BridgeConstants.source.rawValue] as? NSString else {
                return
        }

        var elapsedTime: Double? = nil
        var contentGroup: String? = nil

        if let extensions = config[BridgeConstants.extensions.rawValue] as? NSDictionary,
            let elapsedTimeVar = extensions[BridgeConstants.elapsedTime.rawValue] as? Double {
            elapsedTime = elapsedTimeVar
        }
        if let extensions = config[BridgeConstants.extensions.rawValue] as? NSDictionary,
            let contentGroupVar = extensions[BridgeConstants.contentGroup.rawValue] as? String {
            contentGroup = contentGroupVar
        }

        let src = self.testVideoSrc ?? videoSrc
        startPlayer(src as String, elapsedTime: elapsedTime, identifier: sourceId as String, contentGroup: contentGroup)
    }

    private func startPlayer(_ url: String, elapsedTime: Double?, identifier: String, contentGroup: String?) {
        let sourceItem = PlayableSourceItem(sourceItemUrl: URL(string: url)!, elapsedTime: elapsedTime, identifier: identifier, contentGroup: contentGroup)
        let config = PlayerConfiguration()
        config.playbackConfiguration.isAutoplayEnabled = true
        config.sourceItem = sourceItem

        let player = BitmovinPlayer(configuration: config)
        player.add(listener: self)

        self.analyticCollector = createAnalyticCollector(videoId: identifier)
        self.analyticCollector?.attachBitmovinPlayer(player: player)

        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
                playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                playerView.frame = strongSelf.view.bounds
                playerView.add(listener: strongSelf)

                strongSelf.view.addSubview(playerView)

                strongSelf.bitmovinPlayer = player
                strongSelf.bitmovinPlayerView = playerView
            }
        }
    }

    private func createAnalyticCollector(videoId: String) -> BitmovinAnalytics? {
        guard let analyticKey = self.analyticKey,
            let playerKey = self.playerKey
            else { return nil }

        let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:analyticKey as String, playerKey:playerKey as String)
        config.cdnProvider = CdnProvider.bitmovin
        config.videoId = videoId
        config.heartbeatInterval = self.heartbeatInterval

        return BitmovinAnalytics(config: config);
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPress.PressType.menu) {
            eventsResponderDelegate?.didEndPlayback()
        } else {
            super.pressesBegan(presses, with: event)
        }
    }

    var currentPlayable: PlayableSourceItem? {
        return self.bitmovinPlayer?.config.sourceItem as? PlayableSourceItem
    }

    var playbackState: Progress? {
        guard let playerVar = self.bitmovinPlayer else { return nil }
        return Progress(progress: playerVar.currentTime, duration: playerVar.duration)
    }
 }

