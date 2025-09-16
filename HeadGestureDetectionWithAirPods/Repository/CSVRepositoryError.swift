//
//  CSVRepositoryError.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/19.
//

import Foundation

enum CSVRepositoryError: Error {
    case failedToConvertStringToData
    case failedToCreateURL
}
