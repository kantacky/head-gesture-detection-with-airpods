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
                .frame(height: 180)

            if let pose = presenter.state.currentPose {
                let width = 600.0
                let rate = -pose.yaw / .pi
                let accentColor = if abs(pose.yaw) > .pi / 12 {
                    presenter.state.currentGesture == .nod ? Color.red : Color.green
                } else {
                    Color.blue
                }
                indicator(width: width, rate: rate, accentColor: accentColor)
                    .frame(width: width, height: 24)
            }

            Text("Gesture: \(presenter.state.currentGesture.label)")

            Divider()
            cubes

            Divider()
            HStack(spacing: 16) {
                loggingButton
                resetStartingPoseButton
            }

            //if let motion = presenter.state.motion {
            //    Divider()
            //    motionData(motion)
            //}
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
                ForEach(presenter.state.carouselRange, id: \.self) { index in
                    Text(index.description)
                        .containerRelativeFrame(.horizontal)
                        .frame(maxHeight: .infinity)
                        .font(.largeTitle)
                        .bold()
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
    }

    private func indicator(width: CGFloat, rate: Double, accentColor: Color) -> some View {
        HStack(spacing: 0) {
            if rate < 0 {
                Rectangle()
                    .fill(.secondary)
                    .frame(width: width * 0.5 * (1 + rate))
                Rectangle()
                    .fill(accentColor)
                    .frame(width: width * 0.5 * -rate)
                Rectangle()
                    .fill(.secondary)
                    .frame(width: width * 0.5)
            } else {
                Rectangle()
                    .fill(.secondary)
                    .frame(width: width * 0.5)
                Rectangle()
                    .fill(accentColor)
                    .frame(width: width * 0.5 * rate)
                Rectangle()
                    .fill(.secondary)
                    .frame(width: width * 0.5 * (1 - rate))
            }
        }
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
    private func motionData(_ motion: CMDeviceMotion) -> some View {
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

#Preview {
    HeadGestureScreen()
}
