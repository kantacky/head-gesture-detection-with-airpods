//
//  Gesture.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/09/16.
//

enum Gesture: String {
    case idle
    case nod

    var label: String {
        rawValue.capitalized
    }
}
