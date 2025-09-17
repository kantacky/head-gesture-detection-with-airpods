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
                let attitude_pitch = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let attitude_roll = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let attitude_yaw = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let gravity_x = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let gravity_y = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let gravity_z = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let quaternion_w = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let quaternion_x = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let quaternion_y = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let quaternion_z = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let rotation_rate_x = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let rotation_rate_y = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let rotation_rate_z = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let user_acceleration_x = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let user_acceleration_y = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let user_acceleration_z = try MLMultiArray(shape: [NSNumber(value: 100)], dataType: .double)
                let stateIn = try MLMultiArray(shape: [NSNumber(value: 400)], dataType: .double)
                (0..<100).forEach { attitude_pitch[$0] = NSNumber(value: motions[$0].attitude.pitch) }
                (0..<100).forEach { attitude_roll[$0] = NSNumber(value: motions[$0].attitude.roll) }
                (0..<100).forEach { attitude_yaw[$0] = NSNumber(value: motions[$0].attitude.yaw) }
                (0..<100).forEach { gravity_x[$0] = NSNumber(value: motions[$0].gravity.x) }
                (0..<100).forEach { gravity_y[$0] = NSNumber(value: motions[$0].gravity.y) }
                (0..<100).forEach { gravity_z[$0] = NSNumber(value: motions[$0].gravity.z) }
                (0..<100).forEach { quaternion_w[$0] = NSNumber(value: motions[$0].attitude.quaternion.w) }
                (0..<100).forEach { quaternion_x[$0] = NSNumber(value: motions[$0].attitude.quaternion.x) }
                (0..<100).forEach { quaternion_y[$0] = NSNumber(value: motions[$0].attitude.quaternion.y) }
                (0..<100).forEach { quaternion_z[$0] = NSNumber(value: motions[$0].attitude.quaternion.z) }
                (0..<100).forEach { rotation_rate_x[$0] = NSNumber(value: motions[$0].rotationRate.x) }
                (0..<100).forEach { rotation_rate_y[$0] = NSNumber(value: motions[$0].rotationRate.y) }
                (0..<100).forEach { rotation_rate_z[$0] = NSNumber(value: motions[$0].rotationRate.z) }
                (0..<100).forEach { user_acceleration_x[$0] = NSNumber(value: motions[$0].userAcceleration.x) }
                (0..<100).forEach { user_acceleration_y[$0] = NSNumber(value: motions[$0].userAcceleration.y) }
                (0..<100).forEach { user_acceleration_z[$0] = NSNumber(value: motions[$0].userAcceleration.z) }

                let configuration = MLModelConfiguration()
                let model = try HeadGestureClassifier(configuration: configuration)
                let input = HeadGestureClassifierInput(
                    attitude_pitch: attitude_pitch,
                    attitude_roll: attitude_roll,
                    attitude_yaw: attitude_yaw,
                    gravity_x: gravity_x,
                    gravity_y: gravity_y,
                    gravity_z: gravity_z,
                    quaternion_w: quaternion_w,
                    quaternion_x: quaternion_x,
                    quaternion_y: quaternion_y,
                    quaternion_z: quaternion_z,
                    rotation_rate_x: rotation_rate_x,
                    rotation_rate_y: rotation_rate_y,
                    rotation_rate_z: rotation_rate_z,
                    user_acceleration_x: user_acceleration_x,
                    user_acceleration_y: user_acceleration_y,
                    user_acceleration_z: user_acceleration_z,
                    stateIn: stateIn
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
