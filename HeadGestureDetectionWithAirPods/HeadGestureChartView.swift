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
        }
        .chartForegroundStyleScale(
            [
                "UserAcceleration X": .red,
                "UserAcceleration Y": .green,
                "UserAcceleration Z": .blue,
                "Attitude Roll": .orange,
                "Attitude Pitch": .mint,
                "Attitude Yaw": .purple
            ]
        )
        .chartYScale(domain: [-1, 1])
    }
}

#Preview {
    HeadGestureChartView(motionLogs: [])
}
