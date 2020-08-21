//
//  BulbView.swift
//  LightApp
//
//  Created by Afanasiev, Anatolii on 21/01/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import React
import UIKit

class PlayerView: UIView {
    
    // player
    var playerViewController: PlayerViewController?
    
    // skylark API
    var baseSkylarkUrl: NSString? = nil
    
    var testVideoSrc: NSString? = nil
    var analyticKey: NSString? = nil
    var playerKey: NSString? = nil
    var heartbeatInterval: Int = 0
    
    @objc public var onVideoEnd: RCTBubblingEventBlock?
    
    @objc public var onVideoTimeChanged: RCTBubblingEventBlock?
    
    @objc public var userId: NSString?
    
    @objc var onKeyChanged: NSDictionary? {
        didSet {
        }
    }
    
    deinit {
        playerViewController?.dismiss(animated: false, completion: nil)
        playerViewController?.clean()
        playerViewController = nil
    }
    
    @objc var playableItem: NSDictionary? {
        didSet {
            if playerViewController == nil {
                playerViewController = PlayerViewController()
                playerViewController?.eventsResponderDelegate = self
                playerViewController?.playableItem = playableItem
                playerViewController?.userId = self.userId
                playerViewController?.baseSkylarkUrl = self.baseSkylarkUrl
                playerViewController?.testVideoSrc = self.testVideoSrc
                playerViewController?.analyticKey = self.analyticKey
                playerViewController?.playerKey = self.playerKey
                playerViewController?.heartbeatInterval = self.heartbeatInterval
                
                guard let playerViewController = playerViewController else {
                    return
                }
                let viewController = UIApplication.topViewController()
                viewController?.present(playerViewController, animated: true)
                
            } else {
                playerViewController?.playableItem = playableItem
                playerViewController?.bitmovinPlayer?.play()
            }
        }
    }
        
    public override func insertReactSubview(_ subview: UIView?, at atIndex: Int) {
        if let subview = subview {
            playerViewController?.view.addSubview(subview)
        }
    }
    
    @objc var pluginConfiguration: NSDictionary? {
        didSet {
            
            guard let config = pluginConfiguration,
                let baseSkylarkUrl = config[BridgeConstants.baseSkylarkUrl.rawValue] as? NSString
                else { return }
            
            self.baseSkylarkUrl = baseSkylarkUrl
            
            self.testVideoSrc = config[BridgeConstants.testVideoSrc.rawValue] as? NSString
            if (self.testVideoSrc?.length == 0) {
                self.testVideoSrc = nil
            }
            
            self.analyticKey = config[BridgeConstants.bitmovinAnalyticLicenseKey.rawValue] as? NSString
            self.playerKey = config[BridgeConstants.bitmovinPlayerLicenseKey.rawValue] as? NSString
            self.heartbeatInterval = config[BridgeConstants.heartbeatInterval.rawValue] as? Int ?? CommonConstants.DEFAULT_HEARTBEAT_INTERVAL.rawValue
            
            playerViewController?.baseSkylarkUrl = self.baseSkylarkUrl
            playerViewController?.testVideoSrc = self.testVideoSrc
            playerViewController?.analyticKey = self.analyticKey
            playerViewController?.playerKey = self.playerKey
            playerViewController?.heartbeatInterval = self.heartbeatInterval
            
            if let sourceId = playerViewController?.sourceId as String?, let bitmovinPlayer = playerViewController?.bitmovinPlayer,
              playerViewController?.analyticCollector == nil {
              playerViewController?.analyticCollector = playerViewController?.createAnalyticCollector(videoId: sourceId)
              playerViewController?.analyticCollector?.attachBitmovinPlayer(player: bitmovinPlayer)
            }
        }
    }
    
    public init(eventDispatcher: RCTEventDispatcher) {
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        return nil
    }
}

protocol PlayerEventsResponder: AnyObject {
    func didEndPlayback()
    func onTimeChangedEvent(time: TimeInterval, duration: TimeInterval)
}

extension PlayerView: PlayerEventsResponder {
    func onTimeChangedEvent(time: TimeInterval, duration: TimeInterval) {
        if let onVideoTimeChanged = onVideoTimeChanged {
            onVideoTimeChanged([
                "time": time as Double,
                "duration": duration as Double,
                "target": reactTag ?? NSNull()
            ])
        }
    }
    
    func didEndPlayback() {
        if let onVideoEnd = onVideoEnd {
            onVideoEnd(["target": reactTag ?? NSNull()])
            self.playerViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
