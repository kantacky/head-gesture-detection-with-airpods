//
//  MotionLogCSVRow.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/19.
//

import CoreMotion

struct MotionLogCSVRow {
    let timestamp: Date

    // Attitude
    let attitudeRoll: Double
    let attitudePitch: Double
    let attitudeYaw: Double

    // Gravity
    let gravityX: Double
    let gravityY: Double
    let gravityZ: Double

    // Quaternion
    let quaternionX: Double
    let quaternionY: Double
    let quaternionZ: Double
    let quaternionW: Double

    // RotationRate
    let rotationRateX: Double
    let rotationRateY: Double
    let rotationRateZ: Double

    // UserAcceleration
    let userAccelerationX: Double
    let userAccelerationY: Double
    let userAccelerationZ: Double

    init(motion: CMDeviceMotion) {
        let now = Date()
        let bootTime = now.timeIntervalSince1970 - ProcessInfo.processInfo.systemUptime
        timestamp = Date(timeIntervalSince1970: bootTime + motion.timestamp)
        attitudePitch = motion.attitude.pitch
        attitudeYaw = motion.attitude.yaw
        attitudeRoll = motion.attitude.roll
        gravityX = motion.gravity.x
        gravityY = motion.gravity.y
        gravityZ = motion.gravity.z
        quaternionX = motion.attitude.quaternion.x
        quaternionY = motion.attitude.quaternion.y
        quaternionZ = motion.attitude.quaternion.z
        quaternionW = motion.attitude.quaternion.w
        rotationRateX = motion.rotationRate.x
        rotationRateY = motion.rotationRate.y
        rotationRateZ = motion.rotationRate.z
        userAccelerationX = motion.userAcceleration.x
        userAccelerationY = motion.userAcceleration.y
        userAccelerationZ = motion.userAcceleration.z
    }

    func csvRowString() -> String {
        var list: [String] = []
        list.append(timestamp.formatted(.iso8601.time(includingFractionalSeconds: true)))
        list.append(attitudeRoll.description)
        list.append(attitudePitch.description)
        list.append(attitudeYaw.description)
        list.append(gravityX.description)
        list.append(gravityY.description)
        list.append(gravityZ.description)
        list.append(quaternionX.description)
        list.append(quaternionY.description)
        list.append(quaternionZ.description)
        list.append(quaternionW.description)
        list.append(rotationRateX.description)
        list.append(rotationRateY.description)
        list.append(rotationRateZ.description)
        list.append(userAccelerationX.description)
        list.append(userAccelerationY.description)
        list.append(userAccelerationZ.description)
        return list.joined(separator: ",") + "\n"
    }

    static let csvHeaderString: String = {
        var list: [String] = []
        list.append("timestamp")
        list.append("attitude_roll")
        list.append("attitude_pitch")
        list.append("attitude_yaw")
        list.append("gravity_x")
        list.append("gravity_y")
        list.append("gravity_z")
        list.append("quaternion_x")
        list.append("quaternion_y")
        list.append("quaternion_z")
        list.append("quaternion_w")
        list.append("rotation_rate_x")
        list.append("rotation_rate_y")
        list.append("rotation_rate_z")
        list.append("user_acceleration_x")
        list.append("user_acceleration_y")
        list.append("user_acceleration_z")
        return list.joined(separator: ",") + "\n"
    }()
}
