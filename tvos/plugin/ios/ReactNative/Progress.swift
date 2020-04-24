//
//  Progress.swift
//  BitmovinRNPlayer
//
//  Created by Vladyslav Sumtsov on 3/18/20.
//  Copyright © 2020 Vladyslav Sumtsov. All rights reserved.
//

import Foundation

struct Progress {
    var progress: TimeInterval = .infinity
    var duration: TimeInterval = .infinity
    
    var isValid: Bool {
        return progress.isFinite && duration.isFinite
    }
    
    var isCompleted: Bool {
        return isValid && progress >= duration
    }
}
