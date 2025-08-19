//
//  HeadGesturePresenter.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import CoreMotion
import Observation
import RealityKit

@MainActor
@Observable
final class HeadGesturePresenter {
    @MainActor
    struct State {
        var cubeLeft = ModelEntity()
        var cubeRight = ModelEntity()
        var motion: CMDeviceMotion?
        var startingPose: CMAttitude?
        var currentPose: CMAttitude?
    }

    enum Action {
        case onAppear
        case onDisappear
        case onResetStartingPoseButton
        case makeRealityView
        case updateRealityView
    }

    private(set) var state = State()
    private var trackingTask: Task<Void, Never>?
    private let headphoneMotionManager = HeadphoneMotionManager()

    deinit {
        Task { [weak self] in
            await self?.trackingTask?.cancel()
        }
    }

    func dispatch(_ action: Action) {
        Task {
            await dispatch(action)
        }
    }

    func dispatch(_ action: Action) async {
        switch action {
        case .onAppear:
            onAppear()

        case .onDisappear:
            onDisappear()

        case .onResetStartingPoseButton:
            state.startingPose = nil

        case .makeRealityView:
            makeRealityView()

        case .updateRealityView:
            updateRealityView()
        }
    }
}

private extension HeadGesturePresenter {
    func onAppear() {
        trackingTask = Task {
            do {
                for await motion in try headphoneMotionManager.startTracking() {
                    state.motion = motion
                    if let startingPose = state.startingPose {
                        motion.attitude.multiply(byInverseOf: startingPose)
                    } else {
                        state.startingPose = motion.attitude
                    }
                    state.currentPose = motion.attitude
                    updateRealityView()
                }
            } catch {
                print("Error starting tracking: \(error)")
            }
        }
    }

    func onDisappear() {
        trackingTask?.cancel()
        headphoneMotionManager.stopTracking()
    }

    func makeRealityView() {
        let mesh = MeshResource.generateBox(size: 1, cornerRadius: 0.05)
        let material = SimpleMaterial(color: .blue, roughness: 0.15, isMetallic: true)
        state.cubeLeft = ModelEntity(mesh: mesh, materials: [material])
        state.cubeRight = ModelEntity(mesh: mesh, materials: [material])
        state.cubeLeft.position = SIMD3(x: -1, y: 0, z: 0)
        state.cubeRight.position = SIMD3(x: 1, y: 0, z: 0)
    }

    func updateRealityView() {
        guard
            let motion = state.motion,
            let pose = state.currentPose
        else {
            return
        }
        switch motion.sensorLocation {
        case .default:
            state.cubeLeft.transform.rotation = .init(
                ix: Float(pose.quaternion.x),
                iy: Float(pose.quaternion.z),
                iz: Float(pose.quaternion.y),
                r: -Float(pose.quaternion.w)
            )
            state.cubeRight.transform.rotation = .init(
                ix: Float(pose.quaternion.x),
                iy: Float(pose.quaternion.z),
                iz: Float(pose.quaternion.y),
                r: -Float(pose.quaternion.w)
            )
        case .headphoneLeft:
            state.cubeLeft.transform.rotation = .init(
                ix: Float(pose.quaternion.x),
                iy: Float(pose.quaternion.z),
                iz: Float(pose.quaternion.y),
                r: -Float(pose.quaternion.w)
            )
            state.cubeRight.transform.rotation = .init(ix: 0, iy: 0, iz: 0, r: 0)
        case .headphoneRight:
            state.cubeLeft.transform.rotation = .init(ix: 0, iy: 0, iz: 0, r: 0)
            state.cubeRight.transform.rotation = .init(
                ix: Float(pose.quaternion.x),
                iy: Float(pose.quaternion.z),
                iz: Float(pose.quaternion.y),
                r: -Float(pose.quaternion.w)
            )
        @unknown default:
            return
        }
    }
}
