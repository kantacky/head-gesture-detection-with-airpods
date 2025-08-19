//
//  HeadGestureChartView.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/19.
//

import Charts
import CoreMotion
import SwiftUI

struct HeadGestureChartView: View {
    let motionLogs: [CMDeviceMotion]

    var body: some View {
        Chart(motionLogs, id: \.timestamp) { motion in
            let date = Date(timeIntervalSince1970: motion.timestamp)

            // Attitude
            LineMark(
                x: .value("Date", date),
                y: .value("Attitude Roll", motion.attitude.roll)
            )
            .foregroundStyle(by: .value("Attitude Roll", "Attitude Roll"))
            LineMark(
                x: .value("Date", date),
                y: .value("Attitude Pitch", motion.attitude.pitch)
            )
            .foregroundStyle(by: .value("Attitude Pitch", "Attitude Pitch"))
            LineMark(
                x: .value("Date", date),
                y: .value("Attitude Yaw", motion.attitude.yaw)
            )
            .foregroundStyle(by: .value("Attitude Yaw", "Attitude Yaw"))

            // Gravity
            LineMark(
                x: .value("Date", date),
                y: .value("Gravity X", motion.gravity.x)
            )
            .foregroundStyle(by: .value("Gravity X", "Gravity X"))
            LineMark(
                x: .value("Date", date),
                y: .value("Gravity Y", motion.gravity.y)
            )
            .foregroundStyle(by: .value("Gravity Y", "Gravity Y"))
            LineMark(
                x: .value("Date", date),
                y: .value("Gravity Z", motion.gravity.z)
            )
            .foregroundStyle(by: .value("Gravity Z", "Gravity Z"))

            // Quaternion
            LineMark(
                x: .value("Date", date),
                y: .value("Quaternion X", motion.attitude.quaternion.x)
            )
            .foregroundStyle(by: .value("Quaternion X", "Quaternion X"))
            LineMark(
                x: .value("Date", date),
                y: .value("Quaternion Y", motion.attitude.quaternion.y)
            )
            .foregroundStyle(by: .value("Quaternion Y", "Quaternion Y"))
            LineMark(
                x: .value("Date", date),
                y: .value("Quaternion Z", motion.attitude.quaternion.z)
            )
            .foregroundStyle(by: .value("Quaternion Z", "Quaternion Z"))
            LineMark(
                x: .value("Date", date),
                y: .value("Quaternion W", motion.attitude.quaternion.w)
            )
            .foregroundStyle(by: .value("Quaternion W", "Quaternion W"))

            // RotationRate
            LineMark(
                x: .value("Date", date),
                y: .value("RotationRate X", motion.rotationRate.x)
            )
            .foregroundStyle(by: .value("RotationRate X", "RotationRate X"))
            LineMark(
                x: .value("Date", date),
                y: .value("RotationRate Y", motion.rotationRate.y)
            )
            .foregroundStyle(by: .value("RotationRate Y", "RotationRate Y"))
            LineMark(
                x: .value("Date", date),
                y: .value("RotationRate Z", motion.rotationRate.z)
            )
            .foregroundStyle(by: .value("RotationRate Z", "RotationRate Z"))

            // UserAcceleration
            LineMark(
                x: .value("Date", date),
                y: .value("UserAcceleration X", motion.userAcceleration.x)
            )
            .foregroundStyle(by: .value("UserAcceleration X", "UserAcceleration X"))
            LineMark(
                x: .value("Date", date),
                y: .value("UserAcceleration Y", motion.userAcceleration.y)
            )
            .foregroundStyle(by: .value("UserAcceleration Y", "UserAcceleration Y"))
            LineMark(
                x: .value("Date", date),
                y: .value("UserAcceleration Z", motion.userAcceleration.z)
            )
            .foregroundStyle(by: .value("UserAcceleration Z", "UserAcceleration Z"))
        }
        .chartForegroundStyleScale(
            [
                "Attitude Roll": .red,
                "Attitude Pitch": .green,
                "Attitude Yaw": .orange,
            ]
        )
        .chartYScale(domain: [-1, 1])
    }
}

#Preview {
    HeadGestureChartView(motionLogs: [])
}
