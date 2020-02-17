//
//  PlayerBridge.swift
//  LightApp
//
//  Created by Afanasiev, Anatolii on 21/01/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import React

@objc(PlayerBridge)
class PlayerBridge: RCTViewManager {
    
    static let playerModuleName = "PlayerBridge"
    
    override public static func moduleName() -> String? {
        return PlayerBridge.playerModuleName
    }
    
    override public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override open var methodQueue: DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    override public func view() -> UIView? {
        guard let eventDispatcher = bridge?.eventDispatcher() else {
            return nil
        }
        return PlayerView(eventDispatcher: eventDispatcher)
    }
}
