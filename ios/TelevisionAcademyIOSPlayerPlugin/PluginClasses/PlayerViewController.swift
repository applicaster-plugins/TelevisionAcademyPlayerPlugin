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

class PlayerViewController: UIViewController {

    var player: BitmovinPlayer!

    let videos: [ZPPlayable]
    let configuration: NSDictionary

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        guard let item = videos.first,
            let streamUrl = URL(string: item.contentVideoURLPath()) else {
                return
        }

        // Create player configuration
        let config = PlayerConfiguration()

        do {
            try config.setSourceItem(url: streamUrl)

            // Create player based on player configuration
            let player = BitmovinPlayer(configuration: config)

            // Create player view and pass the player instance to it
            let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            // Listen to player events
            player.add(listener: self)

            playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            playerView.frame = view.bounds

            view.addSubview(playerView)
            view.bringSubviewToFront(playerView)

            self.player = player
        } catch {
            print("Configuration error: \(error)")
        }
    }
}

//MARK:- PlayerListener

extension PlayerViewController: PlayerListener {

    func onPlay(_ event: PlayEvent) {
        print("onPlay \(event.time)")
    }

    func onPaused(_ event: PausedEvent) {
        print("onPaused \(event.time)")
    }

    func onTimeChanged(_ event: TimeChangedEvent) {
        print("onTimeChanged \(event.currentTime)")
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
}
