//
//  PlayerViewController.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 27.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import UIKit
import BitmovinPlayer
import BitmovinAnalyticsCollector
import ZappPlugins
import PlayerEvents
import GoogleCast

class PlayerViewController: UIViewController {
    
    enum Constants: Int {
        case miliseconds = 1000
    }
    private let defaultAnalyticHeartbeat = 5000
    static var lastVideoUrl: String?
    static var lastVideoElapsedTime: Double = 0.0
    private var castingLastVideoElapsedTime: Double = 0.0
    
    // player utils
    var player: BitmovinPlayer?
    private var playerView: BMPBitmovinPlayerView?
    private var analyticCollector: BitmovinAnalytics?
    private var videoStartTime = Date()
    private var viewSwitchCounter = 0
    private var nextPlaylistItem = 0
    private var lastItemFinished = false
    
    // playable data
    let videos: [ZPPlayable]
    let sourceItems: [PlayableSourceItem]
    let configuration: NSDictionary
    let playerEventsManager = PlayerEventsManager()
    
    // general tools
    private var viewAlreadyDidAppear = false
    
    var timer: Timer?
    
    // analytics
    weak var analyticEventDelegate: PlaybackAnalyticEventsDelegate?
    
    // player ui
    fileprivate var customMessageHandler: CustomMessageHandler?
    
    fileprivate var bitmovinUserInterfaceConfiguration: BitmovinUserInterfaceConfiguration {
        let bitmovinUserInterfaceConfiguration = BitmovinUserInterfaceConfiguration()
        customMessageHandler = CustomMessageHandler()
        customMessageHandler?.delegate = self
        bitmovinUserInterfaceConfiguration.customMessageHandler = customMessageHandler
        return bitmovinUserInterfaceConfiguration
    }
    
    required init(with items: [ZPPlayable]?, configurationJSON: NSDictionary?) {
        videos = items ?? []
        configuration = configurationJSON ?? [:]
        if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
            castingLastVideoElapsedTime = remoteMediaClient.approximateStreamPosition()
            remoteMediaClient.pause()
        }
        
        sourceItems = items?.compactMap { (playable) -> PlayableSourceItem in
            let source = PlayableSourceItem(url: URL(string: playable.contentVideoURLPath())!)!
            source.itemTitle = playable.playableName()
            source.playable = playable
            source.elapsedTime = PlayerViewController.convertToDouble(playable.extensionsDictionary?["playhead_position"])
            source.contentGroup = playable.extensionsDictionary?["content_group"] as? String
            return source
        } ?? []
        
        super.init(nibName: nil, bundle: nil)
        
        // Initialize ChromeCast support for this application
        // Initialize bitmovin chrome casting in the ZappGeneralPluginChromeCast_Bitmovin
        // BitmovinCastManager.initializeCasting(applicationId: "3BD10BE7", messageNamespace: nil)
        // Initialize logging
        // BitmovinCastManager.initializeCasting()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        finishPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard viewAlreadyDidAppear == false else {
            return
        }
        
        if let delegate = ZAAppConnector.sharedInstance().chromecastDelegate,
            delegate.isSynced() {
            delegate.play(self.videos, currentPosition: 0)
        }
        
        viewAlreadyDidAppear = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        finishPlayer()
    }
    
    private func finishPlayer() {
        PlayerViewController.lastVideoElapsedTime = player?.currentTime ?? PlayerViewController.lastVideoElapsedTime
        player?.destroy()
        player = nil
        playerView = nil
        analyticCollector?.detachPlayer()
        analyticCollector = nil
    }
    
    private func createAnalyticCollector(videoId: String) -> BitmovinAnalytics? {
        guard let playerKey = configuration["plist.BitmovinPlayerLicenseKey"] as? String else { return nil }
        guard let analyticKey = configuration["BitmovinAnalyticLicenseKey"] as? String else { return nil }
    
        let config:BitmovinAnalyticsConfig = BitmovinAnalyticsConfig(key:analyticKey, playerKey:playerKey)
        config.cdnProvider = CdnProvider.bitmovin
        config.videoId = videoId
        config.heartbeatInterval = Int(self.configuration["heartbeat_interval"] as? String ?? "") ?? defaultAnalyticHeartbeat
          
        return BitmovinAnalytics(config: config);
    }
    
    private func setupPlayer() {
        guard let cssURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.css"),
            let jsURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.js") else {
                print("Please specify the needed resources marked with TODO in ViewController.swift file.")
                dismiss(animated: true, completion: nil)
                return
        }
        
        let config = PlayerConfiguration()
        config.styleConfiguration.playerUiCss = cssURL
        config.styleConfiguration.playerUiJs = jsURL
        config.styleConfiguration.userInterfaceConfiguration = bitmovinUserInterfaceConfiguration
        config.sourceItem = sourceItems.first
        
        let player = BitmovinPlayer(configuration: config)
        player.add(listener: self)
        
        self.analyticCollector = createAnalyticCollector(videoId: sourceItems.first?.playable?.identifier as String? ?? "")
        self.analyticCollector?.attachBitmovinPlayer(player: player)
        
        let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds
        
        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)
        
        self.player = player
        self.playerView = playerView
    }
    
    func didStartPlaybackSession() {
        viewSwitchCounter = 0
        videoStartTime = Date()
    }
    
    private func playNextItem() {
        if (nextPlaylistItem < sourceItems.count) {
            let item = sourceItems[nextPlaylistItem]
            nextPlaylistItem += 1
            
            let sourceConfig = SourceConfiguration()
            sourceConfig.addSourceItem(item: item)
            
            player?.load(sourceConfiguration: sourceConfig)
        }
    }
}

// MARK: - CustomMessageHandlerDelegate
extension PlayerViewController: CustomMessageHandlerDelegate {
    func receivedSynchronousMessage(_ message: String, withData data: String?) -> String? {
        if message == "closePlayer" {
            dismiss(animated: true)  {
                self.finishPlayer()
            }
        }
        return nil
    }
    
    func receivedAsynchronousMessage(_ message: String, withData data: String?) {
        print("received Asynchronouse Messagse", message, data ?? "")
    }
}


//MARK:- PlayerListener

extension PlayerViewController: PlayerListener {
    func onReady(_ event: ReadyEvent) {
        guard let playerVar = player else { return }
            
        // Timeout to workaround starting play when casting
        DispatchQueue.main.asyncAfter(deadline: .now() + (playerVar.isCasting ? 1 : 0)) {
            playerVar.seek(time: self.castingSeekTime())
            playerVar.play()
            self.nextPlaylistItem += 1
        }
        didStartPlaybackSession()
        
        // analytics
        guard let item = playerVar.config.sourceItem as? PlayableSourceItem,
            let currentPlayable = item.playable else { return }
        
        let analyticParamsBuilder = AnalyticParamsBuilder()
        analyticParamsBuilder.duration = playerVar.duration
        analyticParamsBuilder.isLive = currentPlayable.isLive()
        
        let params = currentPlayable.additionalAnalyticsParams.merge(analyticParamsBuilder.parameters)
        let event: AnalyticsEvent = currentPlayable.isLive() ? .live : .vod
        analyticEventDelegate?.eventOccurred(event, params: params, timed: false)
    }
    
    private func castingSeekTime() -> Double {
        
        guard let playerVar = player,
            let item = playerVar.config.sourceItem as? PlayableSourceItem,
            let elapsedTime = item.elapsedTime,
            let videoUrl = item.playable?.contentVideoURLPath() else { return 0.0 }
        
        var component = URLComponents(string: videoUrl)
        component?.query = nil
        let absoluteVideoUrl = component?.url?.absoluteString
        let lastVideoUrl = PlayerViewController.lastVideoUrl
        PlayerViewController.lastVideoUrl = absoluteVideoUrl
        
        if (lastVideoUrl == absoluteVideoUrl) {
            if (self.castingLastVideoElapsedTime > 0) {
                // Starting casting video from it is currently playing.
                return self.castingLastVideoElapsedTime
            } else if (PlayerViewController.lastVideoElapsedTime  > 0) {
                // Starting playing video from it was stopped.
                return PlayerViewController.lastVideoElapsedTime
            }
        }
        return elapsedTime
    }
    
    func onPlay(_ event: PlayEvent) {
        guard let playerVar = player,
            let item = playerVar.config.sourceItem as? PlayableSourceItem else { return }
        
        playerEventsManager.onPlayerEvent("play", properties: [
            "playhead_position" : Int(event.time),
            "content_length" : Int(playerVar.duration),
            "content_uid": getCurrentPlayable?.identifier,
            "content_group": item.contentGroup
        ])
        
        if lastItemFinished {
            nextPlaylistItem = 0
            lastItemFinished = false
        }
    }
    
    func onPaused(_ event: PausedEvent) {
        guard let playerVar = player,
            let sourceItem = playerVar.config.sourceItem as? PlayableSourceItem else { return }
        
        playerEventsManager.onPlayerEvent("pause", properties: [
            "playhead_position" : Int(event.time),
            "content_length" : Int(playerVar.duration),
            "content_uid": getCurrentPlayable?.identifier,
            "content_group": sourceItem.contentGroup
        ])
        
        // analytics
        
        guard let item = getCurrentPlayable,
            let playbackState = getPlaybackState else {
                return
        }
        
        let analyticParamsBuilder = AnalyticParamsBuilder()
        analyticParamsBuilder.progress = playbackState.progress
        analyticParamsBuilder.duration = playbackState.duration
        analyticParamsBuilder.isLive = item.isLive()
        analyticParamsBuilder.durationInVideo = Date().timeIntervalSince(videoStartTime)
        
        let params = item.additionalAnalyticsParams.merge(analyticParamsBuilder.parameters)
        analyticEventDelegate?.eventOccurred(.pause, params: params, timed: false)
    }
    
    func onTimeChanged(_ event: TimeChangedEvent) {
        
        guard let playerVar = player,
            let sourceItem = playerVar.config.sourceItem as? PlayableSourceItem else { return }
        
        if let timerVar = timer,
            timerVar.isValid { return }
        
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        playerEventsManager.onPlayerEvent("heartbeat", properties: [
            "playhead_position" : Int(event.currentTime),
            "content_length" : Int(playerVar.duration),
            "content_uid": getCurrentPlayable?.identifier,
            "content_group": sourceItem.contentGroup
        ])
    }
    
    func onSeek(_ event: SeekEvent) {
        
        // analytics
        
        guard let item = getCurrentPlayable,
            let playbackState = getPlaybackState else {
                return
        }
        
        let from = event.position
        let to = event.seekTarget
        
        let analyticParamsBuilder = AnalyticParamsBuilder()
        analyticParamsBuilder.duration = playbackState.duration
        analyticParamsBuilder.timecodeFrom = from
        analyticParamsBuilder.timecodeTo = to
        analyticParamsBuilder.seekDirection = to > from ? "Fast Forward" : "Rewind"
        
        let params = item.additionalAnalyticsParams.merge(analyticParamsBuilder.parameters)
        analyticEventDelegate?.eventOccurred(.seek, params: params, timed: false)
    }
    
    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        
        guard let playerVar = player,
            let sourceItem = playerVar.config.sourceItem as? PlayableSourceItem else { return }
        
        playerEventsManager.onPlayerEvent("heartbeat", properties: [
            "playhead_position" : 0,
            "content_length" : Int(playerVar.duration),
            "content_uid": getCurrentPlayable?.identifier,
            "content_group": sourceItem.contentGroup
        ])
        
        lastItemFinished = nextPlaylistItem >= sourceItems.count
        if (!lastItemFinished) {
            playNextItem()
        } else {
            self.finishPlayer()
        }
    }
}

//MARK:- Public

extension PlayerViewController {
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func setInlineView(rootViewController: UIViewController, container: UIView) {
        rootViewController.addChildViewController(self, to: container)
        view.matchParent()
        
        playerViewDidTransit(.inline)
    }
    
    func setFullscreenView() {
        let container = self.view.superview
        container?.removeFromSuperview()
        view.matchParent()
        
        playerViewDidTransit(.fullscreen)
    }
    
    var getCurrentPlayable: ZPPlayable? {
        guard let playerVar = player else { return nil }
        
        guard let item = playerVar.config.sourceItem as? PlayableSourceItem else { return nil }
        return item.playable
    }
    
    var getPlaybackState: Progress? {
        guard let playerVar = player else { return nil }
        return Progress(progress: playerVar.currentTime, duration: playerVar.duration)
    }
}

//MARK:- Supporting

extension PlayerViewController {
    
    private func playerViewDidTransit(_ playerScreenMode: PlayerScreenMode) {
        
        guard let item = getCurrentPlayable,
            let playbackState = getPlaybackState else {
                return
        }
        
        viewSwitchCounter += 1
        
        let analyticParamsBuidler = AnalyticParamsBuilder()
        analyticParamsBuidler.progress = playbackState.progress
        analyticParamsBuidler.duration = playbackState.duration
        analyticParamsBuidler.isLive = item.isLive()
        analyticParamsBuidler.durationInVideo = Date().timeIntervalSince(videoStartTime)
        analyticParamsBuidler.newView = playerScreenMode
        analyticParamsBuidler.viewSwitchCounter = viewSwitchCounter
        
        let params = item.additionalAnalyticsParams.merge(analyticParamsBuidler.parameters)
        analyticEventDelegate?.eventOccurred(.playerViewSwitch, params: params, timed: false)
    }
    
    @objc private func timerAction() {
        timer?.invalidate()
    }
    
    class private func convertToDouble(_ value : Any?) -> Double? {
        var valueAsDouble = value as? Double
        if let value = value as? Double {
            valueAsDouble = Double(value)
        }else if let value = value as? String {
            valueAsDouble = Double(value)
        }
        return valueAsDouble
    }
}
