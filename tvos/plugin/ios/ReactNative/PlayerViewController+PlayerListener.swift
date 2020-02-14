//
//  PlayerBridgeView+PlayerListener.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 22.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import BitmovinPlayer

extension PlayerViewController: PlayerListener, UserInterfaceListener {
    
    func onReady(_ event: ReadyEvent) {
        
        guard let item = self.currentPlayable else { return }
        
        if let elapsedTime = item.elapsedTime {
            let time = elapsedTime/Double(CommonConstants.miliseconds.rawValue)
            self.bitmovinPlayer?.seek(time: time)
        }
    }
    
    func onPlay(_ event: PlayEvent) {
        self.trackTime(force: false)
    }
    
    func onPaused(_ event: PausedEvent) {
        self.trackTime(force: false)
    }
    
    func onTimeChanged(_ event: TimeChangedEvent) {
        self.trackTime(force: false)
    }
    
    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        self.trackTime(force: true)
    }
    
    func onEvent(_ event: PlayerEvent) {
        print(event)
    }
}
