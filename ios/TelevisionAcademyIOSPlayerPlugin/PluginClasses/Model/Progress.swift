//
//  Progress.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 13.01.2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
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
