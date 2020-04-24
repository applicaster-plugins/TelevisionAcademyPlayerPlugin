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
    
    private let defaultAnalyticHeartbeat = 5000

    @objc public var onVideoEnd: RCTBubblingEventBlock?
    
    @objc var onKeyChanged: NSDictionary? {
        didSet {
        }
    }
    
    @objc var playableItem: NSDictionary? {
        didSet {
            if playerViewController == nil {
                playerViewController = PlayerViewController()
                playerViewController?.eventsResponderDelegate = self
                playerViewController?.playableItem = playableItem
                playerViewController?.baseSkylarkUrl = self.baseSkylarkUrl
                playerViewController?.testVideoSrc =  self.testVideoSrc
                
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
    
    @objc var pluginConfiguration: NSDictionary? {
        didSet {
            
            guard let config = pluginConfiguration,
                let baseSkylarkUrl = config[BridgeConstants.baseSkylarkUrl.rawValue] as? NSString,
                let analyticKey = config[BridgeConstants.bitmovinAnalyticLicenseKey.rawValue] as? String,
                let playerKey = config[BridgeConstants.bitmovinPlayerLicenseKey.rawValue] as? String
                else { return }
            
            self.baseSkylarkUrl = baseSkylarkUrl
            
            self.testVideoSrc = config[BridgeConstants.testVideoSrc.rawValue] as? NSString
            if (self.testVideoSrc?.length == 0) {
                self.testVideoSrc = nil
            }
            
            let heartbeatInterval = Int(config[BridgeConstants.heartbeatInterval.rawValue] as? String ?? "")
            
            playerViewController?.baseSkylarkUrl = self.baseSkylarkUrl
            playerViewController?.testVideoSrc = self.testVideoSrc
            playerViewController?.analyticKey = analyticKey
            playerViewController?.playerKey = playerKey
            playerViewController?.heartbeatInterval = heartbeatInterval ?? CommonConstants.DEFAULT_HEARTBEAT_INTERVAL.rawValue
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
}

extension PlayerView: PlayerEventsResponder {
    func didEndPlayback() {
        if let onVideoEnd = onVideoEnd {
            onVideoEnd(["target": reactTag ?? NSNull()])
            self.playerViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
