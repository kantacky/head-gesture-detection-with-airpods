//
//  HeadGesturePredictionService.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/09/16.
//

import CoreML
import CoreMotion
import Dependencies
import DependenciesMacros

@DependencyClient
struct HeadGesturePredictionService {
    var predict: @Sendable (_ motions: [CMDeviceMotion]) async throws -> Gesture
}

extension HeadGesturePredictionService: DependencyKey {
    static let liveValue = {
        return HeadGesturePredictionService(
            predict: { motions in
                let configuration = MLModelConfiguration()
                let model = try HeadGestureClassifier(configuration: configuration)
                let input = HeadGestureClassifierInput(
                    rotation_rate_x: try MLMultiArray(motions.map { $0.rotationRate.x }),
                    stateIn: try MLMultiArray(shape: [400], dataType: .double)
                )
                let output = try model.prediction(input: input)
                return Gesture(rawValue: output.label) ?? .idle
            }
        )
    }()
}

extension HeadGesturePredictionService: TestDependencyKey {
    static let testValue = HeadGesturePredictionService()
}
