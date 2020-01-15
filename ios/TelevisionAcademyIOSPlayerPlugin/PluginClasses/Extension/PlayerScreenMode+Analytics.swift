//
//  PlayerScreenMode+Analytics.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 15.01.2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation

extension PlayerScreenMode {
    var analyticsMode: String {
        switch self {
        case .fullscreen:
            return "Full Screen Player"
        case .inline:
            return "Inline Player"
        }
    }
}
