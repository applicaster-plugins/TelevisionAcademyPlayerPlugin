//
//  PlayerBridge.m
//  LightApp
//
//  Created by Afanasiev, Anatolii on 21/01/2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(PlayerBridge, RCTViewManager)

// callback to reactNative
RCT_EXPORT_VIEW_PROPERTY(showSettingsEvent, RCTDirectEventBlock)

// TEST!
RCT_EXTERN_METHOD(playableItem:(NSDictionary)dictionary)
RCT_EXTERN_METHOD(onKeyChanged:(NSDictionary)dictionary)
RCT_EXTERN_METHOD(pluginConfiguration:(NSDictionary)dictionary)
RCT_EXTERN_METHOD(onSettingSelected:(NSDictionary)dictionary)
@end
