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
                    attitude_pitch: try MLMultiArray(motions.map { $0.attitude.pitch }),
                    attitude_roll: try MLMultiArray(motions.map { $0.attitude.roll }),
                    attitude_yaw: try MLMultiArray(motions.map { $0.attitude.yaw }),
                    gravity_x: try MLMultiArray(motions.map { $0.gravity.x }),
                    gravity_y: try MLMultiArray(motions.map { $0.gravity.y }),
                    gravity_z: try MLMultiArray(motions.map { $0.gravity.z }),
                    quaternion_w: try MLMultiArray(motions.map { $0.attitude.quaternion.w }),
                    quaternion_x: try MLMultiArray(motions.map { $0.attitude.quaternion.x }),
                    quaternion_y: try MLMultiArray(motions.map { $0.attitude.quaternion.y }),
                    quaternion_z: try MLMultiArray(motions.map { $0.attitude.quaternion.z }),
                    rotation_rate_x: try MLMultiArray(motions.map { $0.rotationRate.x }),
                    rotation_rate_y: try MLMultiArray(motions.map { $0.rotationRate.y }),
                    rotation_rate_z: try MLMultiArray(motions.map { $0.rotationRate.z }),
                    user_acceleration_x: try MLMultiArray(motions.map { $0.userAcceleration.x }),
                    user_acceleration_y: try MLMultiArray(motions.map { $0.userAcceleration.y }),
                    user_acceleration_z: try MLMultiArray(motions.map { $0.userAcceleration.z }),
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
