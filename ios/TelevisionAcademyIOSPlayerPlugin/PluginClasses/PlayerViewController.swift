//
//  PlayerViewController.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 27.12.2019.
//  Copyright © 2019 Applicaster Ltd. All rights reserved.
//

import UIKit
import BitmovinPlayer
import ZappPlugins
import PlayerEvents

class PlayerViewController: UIViewController {

    enum Constants: Int {
        case miliseconds = 1000
    }

    // player utils
    var player: BitmovinPlayer?
    private var playerView: BMPBitmovinPlayerView?
    private var videoStartTime = Date()
    private var viewSwitchCounter = 0

    // playable data
    let videos: [ZPPlayable]
    let configuration: NSDictionary
    let playerEventsManager = PlayerEventsManager()

    // general tools
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

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        player?.destroy()
        player = nil
        playerView = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
    }

    private func setupPlayer() {

        let config = PlayerConfiguration()

        guard let cssURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.css"),
            let jsURL = Bundle.main.url(forResource: "bitmovinplayer-ui", withExtension: "min.js") else {
                print("Please specify the needed resources marked with TODO in ViewController.swift file.")
                dismiss(animated: true, completion: nil)
                return
        }
        config.styleConfiguration.playerUiCss = cssURL
        config.styleConfiguration.playerUiJs = jsURL
        config.styleConfiguration.userInterfaceConfiguration = bitmovinUserInterfaceConfiguration


        let sourceItems =
            videos.map { (playable) -> PlayableSourceItem in
                let source = PlayableSourceItem(url: URL(string: playable.contentVideoURLPath())!)!
                source.itemTitle = playable.playableName()
                source.playable = playable
                source.elapsedTime = playable.extensionsDictionary?["elapsed_time"] as? Double

                return source
        }

        config.playbackConfiguration.isAutoplayEnabled = true
        config.sourceItem = sourceItems.first

        let player = BitmovinPlayer(configuration: config)
        player.add(listener: self)

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
}

// MARK: - CustomMessageHandlerDelegate
extension PlayerViewController: CustomMessageHandlerDelegate {
    func receivedSynchronousMessage(_ message: String, withData data: String?) -> String? {
        if message == "closePlayer" {
            player?.pause()
            dismiss(animated: true)  {
                self.player = nil
                self.playerView = nil
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
        
        guard let playerVar = player,
            let item = playerVar.config.sourceItem as? PlayableSourceItem else { return }

        if let elapsedTime = item.elapsedTime {
            let time = elapsedTime/Double(Constants.miliseconds.rawValue)
            playerVar.seek(time: time)
            didStartPlaybackSession()
        }

        // analytics

        guard let currentPlayable = item.playable else { return }

        let analyticParamsBuilder = AnalyticParamsBuilder()
        analyticParamsBuilder.duration = playerVar.duration
        analyticParamsBuilder.isLive = currentPlayable.isLive()

        let params = currentPlayable.additionalAnalyticsParams.merge(analyticParamsBuilder.parameters)
        let event: AnalyticsEvent = currentPlayable.isLive() ? .live : .vod
        analyticEventDelegate?.eventOccurred(event, params: params, timed: false)
    }

    func onPlay(_ event: PlayEvent) {

        guard let playerVar = player else { return }

        let miliseconds = event.time * Double(Constants.miliseconds.rawValue)
        let length = playerVar.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable?.identifier

        playerEventsManager.onPlayerEvent("play", properties: [
            "elapsed_time" : miliseconds,
            "content_length" : length,
            "content_uid": uid
        ])
    }

    func onPaused(_ event: PausedEvent) {

        guard let playerVar = player else { return }

        let miliseconds = event.time * Double(Constants.miliseconds.rawValue)
        let length = playerVar.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable?.identifier

        playerEventsManager.onPlayerEvent("pause", properties: [
            "elapsed_time" : miliseconds,
            "content_length" : length,
            "content_uid": uid
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

        guard let playerVar = player else { return }

        if let timerVar = timer,
            timerVar.isValid { return }

        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

        let miliseconds = event.currentTime * Double(Constants.miliseconds.rawValue)
        let length = playerVar.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable?.identifier

        playerEventsManager.onPlayerEvent("heartbeat", properties: [
            "elapsed_time" : miliseconds,
            "content_length" : length,
            "content_uid": uid
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

        guard let playerVar = player else { return }

        let length = playerVar.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable?.identifier

        playerEventsManager.onPlayerEvent("heartbeat", properties: [
            "elapsed_time" : 0,
            "content_length" : length,
            "content_uid": uid
        ])
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
}
