//
//  HeadGestureView.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import RealityKit
import SwiftUI

struct HeadGestureView: View {
    @State private var presenter = HeadGesturePresenter()
    @State private var cubeLeft = ModelEntity()
    @State private var cubeRight = ModelEntity()

    var body: some View {
        VStack {
            RealityView { content in
                let mesh = MeshResource.generateBox(size: 1, cornerRadius: 0.05)
                let material = SimpleMaterial(color: .blue, roughness: 0.15, isMetallic: true)
                cubeLeft = ModelEntity(mesh: mesh, materials: [material])
                cubeRight = ModelEntity(mesh: mesh, materials: [material])
                cubeLeft.position = SIMD3(x: -1, y: 0, z: 0)
                cubeRight.position = SIMD3(x: 1, y: 0, z: 0)
                content.add(cubeLeft)
                content.add(cubeRight)
            } update: { content in
                guard
                    let motion = presenter.state.motion,
                    let pose = presenter.state.currentPose
                else {
                    return
                }
                switch motion.sensorLocation {
                case .default:
                    cubeLeft.transform.rotation = .init(
                        ix: Float(pose.quaternion.x),
                        iy: Float(pose.quaternion.z),
                        iz: Float(pose.quaternion.y),
                        r: -Float(pose.quaternion.w)
                    )
                    cubeRight.transform.rotation = .init(
                        ix: Float(pose.quaternion.x),
                        iy: Float(pose.quaternion.z),
                        iz: Float(pose.quaternion.y),
                        r: -Float(pose.quaternion.w)
                    )
                case .headphoneLeft:
                    cubeLeft.transform.rotation = .init(
                        ix: Float(pose.quaternion.x),
                        iy: Float(pose.quaternion.z),
                        iz: Float(pose.quaternion.y),
                        r: -Float(pose.quaternion.w)
                    )
                    cubeRight.transform.rotation = .init(ix: 0, iy: 0, iz: 0, r: 0)
                case .headphoneRight:
                    cubeLeft.transform.rotation = .init(ix: 0, iy: 0, iz: 0, r: 0)
                    cubeRight.transform.rotation = .init(
                        ix: Float(pose.quaternion.x),
                        iy: Float(pose.quaternion.z),
                        iz: Float(pose.quaternion.y),
                        r: -Float(pose.quaternion.w)
                    )
                @unknown default:
                    return
                }
            }

            if let pose = presenter.state.startingPose {
                HStack {
                    Text("Starting Pose (Roll, Pitch, Yaw):")
                    Text(pose.roll, format: .number.precision(.fractionLength(2)))
                    Text(pose.pitch, format: .number.precision(.fractionLength(2)))
                    Text(pose.yaw, format: .number.precision(.fractionLength(2)))
                }
            }

            if let pose = presenter.state.currentPose {
                HStack {
                    Text("Current Pose (Roll, Pitch, Yaw):")
                    Text(pose.roll, format: .number.precision(.fractionLength(2)))
                    Text(pose.pitch, format: .number.precision(.fractionLength(2)))
                    Text(pose.yaw, format: .number.precision(.fractionLength(2)))
                }
            }

            Button("Reset Starting Pose") {
                presenter.dispatch(.onResetStartingPoseButton)
            }
        }
        .padding()
        .onAppear {
            presenter.dispatch(.onAppear)
        }
        .onDisappear {
            presenter.dispatch(.onDisappear)
        }
    }
}

#Preview {
    HeadGestureView()
}
