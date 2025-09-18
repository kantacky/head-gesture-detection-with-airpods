//
//  HeadGestureScreen.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import CoreMotion
import RealityKit
import SwiftUI

struct HeadGestureScreen: View {
    @State private var presenter = HeadGesturePresenter()

    var body: some View {
        VStack(spacing: 16) {
            carousel

            cubes

            loggingButton

            resetStartingPoseButton

            Divider()

            motionData(presenter.state.motion)

            Divider()

            Text("Gesture: \(presenter.state.currentGesture.label)")
        }
        .onAppear {
            presenter.dispatch(.onAppear)
        }
        .onDisappear {
            presenter.dispatch(.onDisappear)
        }
        .padding(.vertical, 16)
    }

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0..<10) { index in
                    Text(index.description)
                        .containerRelativeFrame(.horizontal)
                        .frame(maxHeight: .infinity)
                        .background(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $presenter.state.scrollPosition)
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 24)
        .frame(height: 120)
    }

    private var cubes: some View {
        RealityView { content in
            await presenter.dispatch(.makeRealityView)
            content.add(presenter.state.cubeLeft)
            content.add(presenter.state.cubeRight)
        }
    }

    private var loggingButton: some View {
        Button(presenter.state.isLogging ? "Stop Logging" : "Start Logging") {
            presenter.dispatch(.onLoggingButtonTapped)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
    }

    private var resetStartingPoseButton: some View {
        Button("Reset Starting Pose") {
            presenter.dispatch(.onResetStartingPoseButtonTapped)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
    }

    @ViewBuilder
    private func motionData(_ motion: CMDeviceMotion?) -> some View {
        if let motion {
            HStack {
                VStack(alignment: .leading) {
                    Text("attitude_pitch")
                    Text("attitude_roll")
                    Text("attitude_yaw")
                    Text("gravity_x")
                    Text("gravity_y")
                    Text("gravity_z")
                    Text("quaternion_w")
                    Text("quaternion_x")
                    Text("quaternion_y")
                    Text("quaternion_z")
                    Text("rotation_rate_x")
                    Text("rotation_rate_y")
                    Text("rotation_rate_z")
                    Text("user_acceleration_x")
                    Text("user_acceleration_y")
                    Text("user_acceleration_z")
                }
                VStack(alignment: .trailing) {
                    Text(motion.attitude.pitch, format: .number.precision(.fractionLength(4)))
                    Text(motion.attitude.roll, format: .number.precision(.fractionLength(4)))
                    Text(motion.attitude.yaw, format: .number.precision(.fractionLength(4)))
                    Text(motion.gravity.x, format: .number.precision(.fractionLength(4)))
                    Text(motion.gravity.y, format: .number.precision(.fractionLength(4)))
                    Text(motion.gravity.z, format: .number.precision(.fractionLength(4)))
                    Text(motion.attitude.quaternion.w, format: .number.precision(.fractionLength(4)))
                    Text(motion.attitude.quaternion.x, format: .number.precision(.fractionLength(4)))
                    Text(motion.attitude.quaternion.y, format: .number.precision(.fractionLength(4)))
                    Text(motion.attitude.quaternion.z, format: .number.precision(.fractionLength(4)))
                    Text(motion.rotationRate.x, format: .number.precision(.fractionLength(4)))
                    Text(motion.rotationRate.y, format: .number.precision(.fractionLength(4)))
                    Text(motion.rotationRate.z, format: .number.precision(.fractionLength(4)))
                    Text(motion.userAcceleration.x, format: .number.precision(.fractionLength(4)))
                    Text(motion.userAcceleration.y, format: .number.precision(.fractionLength(4)))
                    Text(motion.userAcceleration.z, format: .number.precision(.fractionLength(4)))
                }
            }
            .fontDesign(.monospaced)
        }
    }
}

#Preview {
    HeadGestureScreen()
}
