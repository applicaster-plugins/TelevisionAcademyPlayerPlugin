//
//  PlayerBridge.m
//  LightApp
//
//  Created by Afanasiev, Anatolii on 21/01/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

@import React;
#import <AVFoundation/AVFoundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(PlayerBridge, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(playableItem, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(pluginConfiguration, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(onVideoEnd, RCTBubblingEventBlock);

@end
