//
//  String+Utils.swift
//  TelevisionAcademyIOSPlayerPlugin
//
//  Created by Anatoliy Afanasev on 13.01.2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Foundation

extension String {

    public static func create(fromInterval interval: TimeInterval) -> String {

        guard interval.isNormal == true else {  return "" }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        return formatter.string(from: interval) ?? ""
    }
}
