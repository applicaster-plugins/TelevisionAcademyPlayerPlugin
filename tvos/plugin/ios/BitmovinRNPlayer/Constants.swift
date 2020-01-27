//
//  Constants.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 23.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

enum BridgeConstants: String {
  case VIDEO_QUALITY_TYPE = "video_quality"
  case AUDIO_TRACK_TYPE = "audio_quality"
  case LANGUAGE_SUBTITLE_TYPE = "language_subtitle"

  case content = "content"
  case id = "id"
  case source = "src"
  case extensions = "extensions"
  case elapsedTime = "elapsed_time"
  case baseSkylarkUrl = "baseSkylarkUrl"
  case testVideoSrc = "testVideoSrc"
  case type = "type"
  case keyCode = "keyCode"
}

enum CommonConstants: Int {
  case miliseconds = 1000
  case SEEKING_OFFSET = 10
  case TRACK_TIME_INTERVAL = 5
}

enum RemoteControlKeys: Int {
  case KEYCODE_DPAD_CENTER = 23
  case KEYCODE_ENTER = 66
  case KEYCODE_NUMPAD_ENTER = 160
  case KEYCODE_SPACE = 62
  case KEYCODE_MEDIA_PLAY_PAUSE = 85
  case KEYCODE_MEDIA_PLAY = 126
  case KEYCODE_MEDIA_PAUSE = 127
  case KEYCODE_MEDIA_STOP = 86
  case KEYCODE_DPAD_RIGHT = 22
  case KEYCODE_MEDIA_FAST_FORWARD = 90
  case KEYCODE_MEDIA_REWIND = 89
  case KEYCODE_DPAD_LEFT = 21
  case KEYCODE_MENU = 82
}
