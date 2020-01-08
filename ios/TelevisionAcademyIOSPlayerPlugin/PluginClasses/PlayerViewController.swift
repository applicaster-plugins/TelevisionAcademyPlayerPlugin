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

    // player utils
    var player: BitmovinPlayer!
    var playerView: UIView!

    // playable data
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
        videos.map { (playable) -> SourceItem in
            let source = SourceItem(url: URL(string: playable.contentVideoURLPath())!)!
            source.itemTitle = playable.playableName()

            return source
        }

        let config = PlayerConfiguration()
        config.sourceItem = sourceItems.first

        let p = BitmovinPlayer(configuration: config)
        p.add(listener: self)

        let v = BMPBitmovinPlayerView(player: p, frame: .zero)
        v.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        v.frame = view.bounds

        view.addSubview(v)
        view.bringSubviewToFront(v)

        self.player = p
        self.playerView = v
    }
}

//MARK:- PlayerListener

extension PlayerViewController: PlayerListener {

    public func onMetadata(_ event: MetadataEvent) {
        for entry in event.metadata.entries {
            if let metadataEntry = entry as? AVMetadataItem,
                let id3Key = metadataEntry.key {
                print("Received metadata with key: \(id3Key)")
            }
        }
    }

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
