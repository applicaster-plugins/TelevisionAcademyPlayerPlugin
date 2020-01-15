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
    var player: BitmovinPlayer!
    var playerView: BMPBitmovinPlayerView!
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

    required init(with items: [ZPPlayable]?, configurationJSON: NSDictionary?) {
        videos = items ?? []
        configuration = configurationJSON ?? [:]

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        player.destroy()
        player = nil
        playerView = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
    }

    private func setupPlayer() {

        let sourceItems =
            videos.map { (playable) -> PlayableSourceItem in
                let source = PlayableSourceItem(url: URL(string: playable.contentVideoURLPath())!)!
                source.itemTitle = playable.playableName()
                source.playable = playable
                source.elapsedTime = playable.extensionsDictionary?["elapsed_time"] as? Double

                return source
        }

        let config = PlayerConfiguration()
        config.playbackConfiguration.isAutoplayEnabled = true
        config.sourceItem = sourceItems.first
        
        let p = BitmovinPlayer(configuration: config)
        p.add(listener: self)

        let v = BMPBitmovinPlayerView(player: p, frame: .zero)
        v.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        v.frame = view.bounds
        v.add(listener: self)

        view.addSubview(v)
        view.bringSubviewToFront(v)

        self.player = p
        self.playerView = v
    }

    func didStartPlaybackSession() {
        viewSwitchCounter = 0
        videoStartTime = Date()
    }
}

//MARK:- UserInterfaceListener

extension PlayerViewController: UserInterfaceListener {
    func onControlsShow(_ event: ControlsShowEvent) {
        // Show the close button
    }
    func onControlsHide(_ event: ControlsHideEvent) {
        // Hide the close button
    }
}

//MARK:- PlayerListener

extension PlayerViewController: PlayerListener {

    func onReady(_ event: ReadyEvent) {

        guard let item = self.player.config.sourceItem as? PlayableSourceItem,
            let elapsedTime = item.elapsedTime else {
                return
        }

        let time = elapsedTime/Double(Constants.miliseconds.rawValue)
        player.seek(time: time)

        didStartPlaybackSession()

        // analytics

        guard let currentPlayable = item.playable else { return }

        let analyticParamsBuilder = AnalyticParamsBuilder()
        analyticParamsBuilder.duration = player.duration
        analyticParamsBuilder.isLive = currentPlayable.isLive()

        let params = currentPlayable.additionalAnalyticsParams.merge(analyticParamsBuilder.parameters)
        let event: AnalyticsEvent = currentPlayable.isLive() ? .live : .vod
        analyticEventDelegate?.eventOccurred(event, params: params, timed: false)
    }

    func onPlay(_ event: PlayEvent) {
        print("onPlay \(event.time)")

        let miliseconds = event.time * Double(Constants.miliseconds.rawValue)
        let lenght = player.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable()?.identifier

        playerEventsManager.onPlayerEvent("play", properties: [
            "elapsed_time" : miliseconds,
            "content_length" : lenght,
            "content_uid": uid
        ])
    }

    func onPaused(_ event: PausedEvent) {

        print("onPaused \(event.time)")

        let miliseconds = event.time * Double(Constants.miliseconds.rawValue)
        let lenght = player.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable()?.identifier

        playerEventsManager.onPlayerEvent("pause", properties: [
            "elapsed_time" : miliseconds,
            "content_length" : lenght,
            "content_uid": uid
        ])

        // analytics

        guard let item = getCurrentPlayable(),
            let playbackState = getPlaybackState() else {
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

        if let t = timer,
            t.isValid { return }

        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

        let miliseconds = event.currentTime * Double(Constants.miliseconds.rawValue)
        let lenght = player.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable()?.identifier

        playerEventsManager.onPlayerEvent("heartbeat", properties: [
            "elapsed_time" : miliseconds,
            "content_length" : lenght,
            "content_uid": uid
        ])
    }

    func onSeek(_ event: SeekEvent) {

        // analytics

        guard let item = getCurrentPlayable(),
            let playbackState = getPlaybackState() else {
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
        let lenght = player.duration * Double(Constants.miliseconds.rawValue)
        let uid = getCurrentPlayable()?.identifier

        playerEventsManager.onPlayerEvent("heartbeat", properties: [
            "elapsed_time" : 0,
            "content_length" : lenght,
            "content_uid": uid
        ])
    }
}

//MARK:- Public

extension PlayerViewController {

    func pause() {
        player.pause()
    }

    func stop() {
        player.pause()
    }

    func play() {
        player.play()
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
}

//MARK:- General

extension PlayerViewController {

    func getCurrentPlayable() -> ZPPlayable? {
        guard let item = self.player.config.sourceItem as? PlayableSourceItem else { return nil }
        return item.playable
    }

    func getPlaybackState() -> Progress? {
        return Progress(progress: player.currentTime, duration: player.duration)
    }

    private func playerViewDidTransit(_ playerScreenMode: PlayerScreenMode) {

        guard let item = getCurrentPlayable(),
            let playbackState = getPlaybackState() else {
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
