//
//  PlayableSourceItem.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 09.01.2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation
import BitmovinPlayer
import ZappPlugins

class PlayableSourceItem: SourceItem {
    var elapsedTime: Double? = nil
    var playable: ZPPlayable? = nil
}
