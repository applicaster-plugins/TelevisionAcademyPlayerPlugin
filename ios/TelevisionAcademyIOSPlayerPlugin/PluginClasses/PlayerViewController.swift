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

    // playable data
    let videos: [ZPPlayable]
    let configuration: NSDictionary
    let playerEventsManager = PlayerEventsManager()

    // general tools
    var timer: Timer?

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
        self.player.seek(time: time)
    }

    func onPlay(_ event: PlayEvent) {
        print("onPlay \(event.time)")
        playerEventsManager.onPlayerEvent("play", properties: [:])
    }

    func onPaused(_ event: PausedEvent) {
        print("onPaused \(event.time)")
        playerEventsManager.onPlayerEvent("pause", properties: [:])
    }

    func onTimeChanged(_ event: TimeChangedEvent) {

        if let t = timer,
            t.isValid { return }

        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

        print("onTimeChanged \(event.currentTime)")
        let miliseconds = event.currentTime * Double(Constants.miliseconds.rawValue)
        playerEventsManager.onPlayerEvent("heartbeat", properties: ["elapsed_time" : miliseconds]) //in miliseconds
    }

    @objc func timerAction() {
        timer?.invalidate()
    }

    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        print("onPlaybackFinished \(event.timestamp)")
        playerEventsManager.onPlayerEvent("stop", properties: [:])
    }

    func onDurationChanged(_ event: DurationChangedEvent) {
        print("onDurationChanged \(event.duration)")
    }

    func onError(_ event: ErrorEvent) {
        print("onError \(event.message)")
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
    }

    func setFullscreenView() {
        let container = self.view.superview
        container?.removeFromSuperview()
        view.matchParent()
    }
}
