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
        var scrollPosition: Int? = 0
        var cubeLeft = ModelEntity()
        var cubeRight = ModelEntity()
        var motion: CMDeviceMotion?
        var startingPose: CMAttitude?
        var currentPose: CMAttitude?
        var motionLogs: [CMDeviceMotion] = []
        var isSavingMotionLogs: Bool = false
    }

    enum Action {
        case onAppear
        case onDisappear
        case onResetStartingPoseButton
        case makeRealityView
    }

    var state = State()
    private var trackingTask: Task<Void, Never>?
    private let headphoneMotionManager = HeadphoneMotionManager()
    private let motionLogCSVManager = MotionLogCSVManager()

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
        }
    }
}

private extension HeadGesturePresenter {
    func onAppear() {
        trackingTask = Task {
            do {
                for await motion in try headphoneMotionManager.startTracking() {
                    state.motion = motion
                    updateMotionLogs()
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
            state.cubeLeft.transform.rotation = pose.quaternion.simd_quatf
            state.cubeRight.transform.rotation = pose.quaternion.simd_quatf
        case .headphoneLeft:
            state.cubeLeft.transform.rotation = pose.quaternion.simd_quatf
            state.cubeRight.transform.rotation = .init(ix: 0, iy: 0, iz: 0, r: 0)
        case .headphoneRight:
            state.cubeLeft.transform.rotation = .init(ix: 0, iy: 0, iz: 0, r: 0)
            state.cubeRight.transform.rotation = pose.quaternion.simd_quatf
        @unknown default:
            return
        }
    }

    func updateMotionLogs() {
        guard let motion = state.motion else {
            return
        }
        if state.motionLogs.count >= 128 {
            state.motionLogs.removeFirst()
        }
        state.motionLogs.append(motion)
        if state.isSavingMotionLogs {
            saveMotionLog(motion: motion)
        } else {
            Task {
                try? await motionLogCSVManager.close()
            }
        }
    }

    func saveMotionLog(motion: CMDeviceMotion) {
        let row = MotionLogCSVRow(motion: motion)
        Task {
            do {
                try await motionLogCSVManager.write(row.csvRowString())
            } catch let error as MotionLogCSVManagerError {
                if case .fileNotOpened = error {
                    try await motionLogCSVManager.createAndOpen(header: MotionLogCSVRow.csvHeaderString)
                    try await motionLogCSVManager.write(row.csvRowString())
                }
            } catch {
                print("Failed to write motion log CSV file: \(error)")
            }
        }
    }
}

private extension CMQuaternion {
    var simd_quatf: simd_quatf {
        .init(
            ix: Float(x),
            iy: Float(z),
            iz: Float(y),
            r: -Float(w)
        )
    }
}
