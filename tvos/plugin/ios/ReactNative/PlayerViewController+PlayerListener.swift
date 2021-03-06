//
//  PlayerBridgeView+PlayerListener.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 22.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import BitmovinPlayer
import ZappCore

extension PlayerViewController: PlayerListener, UserInterfaceListener {
    
    func onReady(_ event: ReadyEvent) {
        
        guard let item = self.currentPlayable else { return }
        
        self.skipSeekTrack = true
        let params = AnalyticParamsBuilder()
        if let elapsedTime = item.elapsedTime {
            self.bitmovinPlayer?.seek(time: elapsedTime)
            params.progress = elapsedTime
        }
        self.skipSeekTrack = false
        
        guard let playbackState = playbackState else {
            return
        }
        
        params.duration = playbackState.duration
        FacadeConnector.connector?.analytics?.startObserveTimedEvent?(name: AnalyticsEvent.vod.rawValue, parameters: params.parameters)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let playbackState = playbackState else {
            return
        }
        
        let params = AnalyticParamsBuilder()
        params.progress = playbackState.progress
        params.duration = playbackState.duration
        FacadeConnector.connector?.analytics?.stopObserveTimedEvent?(AnalyticsEvent.vod.rawValue, parameters: params.parameters)
    }
    
    func onPlay(_ event: PlayEvent) {
        //We don't track play events when time is 0
        guard let currentTime = bitmovinPlayer?.currentTime,
            Int(currentTime) > 0 else {
            return
        }

        self.trackTime(force: false)
    }
    
    func onPaused(_ event: PausedEvent) {
        //We don't track pause events when time is 0
        guard let currentTime = bitmovinPlayer?.currentTime,
            Int(currentTime) > 0 else {
            return
        }
        
        self.trackTime(force: false)
        
        // analytics
        guard let playbackState = playbackState else {
            return
        }
        
        let params = AnalyticParamsBuilder()
        params.progress = playbackState.progress
        params.duration = playbackState.duration
        
        FacadeConnector.connector?.analytics?.sendEvent?(name: AnalyticsEvent.pause.rawValue, parameters: params.parameters)
    }
    
    func onTimeChanged(_ event: TimeChangedEvent) {
        //We don't track onTimeChanged events when time is 0
        if let currentTime = bitmovinPlayer?.currentTime, Int(currentTime) > 0 {
            self.trackTime(force: false)
        }
        eventsResponderDelegate?.onTimeChangedEvent(time: event.currentTime, duration: (self.bitmovinPlayer?.duration ?? 0))
    }
    
    func onSeek(_ event: SeekEvent) {
        // analytics
        if (self.skipSeekTrack) {
            return
        }
        guard let playbackState = playbackState else {
            return
        }
        
        let from = event.position
        let to = event.seekTarget
        
        let params = AnalyticParamsBuilder()
        params.duration = playbackState.duration
        params.timecodeFrom = from
        params.timecodeTo = to
        params.seekDirection = to > from ? "Fast Forward" : "Rewind"
        
        FacadeConnector.connector?.analytics?.sendEvent?(name: AnalyticsEvent.seek.rawValue, parameters: params.parameters)
    }
    
    func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        self.trackTime(force: true)
    }
    
    func onEvent(_ event: PlayerEvent) {
        print(event)
    }
    
    func onError() {
        
    }
}
