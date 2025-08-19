//
//  MotionLogCSVManagerError.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/19.
//

import Foundation

enum MotionLogCSVManagerError: Error {
    case failedToConvertStringToData
    case failedToCreateURL
    case fileNotOpened
}
