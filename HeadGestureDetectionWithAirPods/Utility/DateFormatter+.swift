//
//  DateFormatter+.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/09/16.
//

import Foundation

extension DateFormatter {
    static let fileName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        return formatter
    }()
}
