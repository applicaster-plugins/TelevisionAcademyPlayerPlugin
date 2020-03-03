//
//  PlayableSourceItem.swift
//  LightApp
//
//  Created by Anatoliy Afanasev on 22.01.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import BitmovinPlayer

class PlayableSourceItem: SourceItem {
    var elapsedTime: Double?
    var identifier: String
    var contentGroup: String?
    
    init?(sourceItemUrl: URL, elapsedTime: Double?, identifier: String, contentGroup: String?) {
        self.elapsedTime = elapsedTime
        self.identifier = identifier
        self.contentGroup = contentGroup
        super.init(url: sourceItemUrl)
    }
}
