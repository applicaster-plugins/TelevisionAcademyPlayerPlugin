//
//  PlayerBridge.swift
//  LightApp
//
//  Created by Afanasiev, Anatolii on 21/01/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import BitmovinPlayer

@objc(PlayerBridge)
class PlayerBridge: RCTViewManager {
  
  let bulbView: PlayerView = PlayerView()

  override func view() -> UIView! {
    return self.bulbView
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc
  func playableItem(_ dictionary: NSDictionary) {
    self.bulbView.playableItem = dictionary
  }

  @objc
  func onKeyChanged(_ dictionary: NSDictionary) {
    self.bulbView.onKeyChanged = dictionary
  }

  @objc
  func pluginConfiguration(_ dictionary: NSDictionary) {
    self.bulbView.pluginConfiguration = dictionary
  }

  @objc
  func onSettingSelected(_ dictionary: NSDictionary) {
    self.bulbView.onSettingSelected = dictionary
  }
}
