//
//  HeadGesturePresenter.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import CoreMotion
import Dependencies
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
        var isLogging: Bool = false
    }

    enum Action {
        case onAppear
        case onDisappear
        case onLoggingButtonTapped
        case onResetStartingPoseButtonTapped
        case makeRealityView
    }

    var state = State()
    @ObservationIgnored
    @Dependency(MotionService.self) private var motionService
    @ObservationIgnored
    @Dependency(CSVService.self) private var csvService
    @ObservationIgnored
    private var trackingTask: Task<Void, Never>?
    @ObservationIgnored
    private var csvFile: FileHandle?

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

        case .onLoggingButtonTapped:
            state.isLogging.toggle()

        case .onResetStartingPoseButtonTapped:
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
                for await motion in try motionService.startTracking() {
                    state.motion = motion
                    updateMotionLogs(newValue: motion)
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
        motionService.stopTracking()
    }

    func makeRealityView() {
        let mesh = MeshResource.generateBox(size: 1, cornerRadius: 0.05)
        let material = SimpleMaterial(color: .blue, roughness: 0.15, isMetallic: true)
        state.cubeLeft = ModelEntity(mesh: mesh, materials: [material])
        state.cubeRight = ModelEntity(mesh: mesh, materials: [material])
        state.cubeLeft.position = SIMD3(x: -1, y: 0, z: 0)
        state.cubeRight.position = SIMD3(x: 1, y: 0, z: 0)
    }
}

private extension HeadGesturePresenter {
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

    func updateMotionLogs(newValue: CMDeviceMotion) {
        if state.motionLogs.count >= 64 {
            state.motionLogs.removeFirst()
        }
        state.motionLogs.append(newValue)
        if state.isLogging {
            saveMotionLog(motion: newValue)
        } else {
            Task {
                guard let file = csvFile else {
                    return
                }
                try? csvService.close(file)
            }
        }
    }

    func saveMotionLog(motion: CMDeviceMotion) {
        do {
            if csvFile == nil {
                let formatter = ISO8601DateFormatter()
                let filename = formatter.string(from: .now)
                let file = try csvService.create(
                    header: MotionLogCSVRow.csvHeaderString,
                    filename: filename
                )
                csvFile = file
            }
            guard let file = csvFile else {
                return
            }
            let row = MotionLogCSVRow(motion: motion)
            try csvService.write(row.csvRowString(), file)
        } catch {
            print("Failed to write motion log CSV file: \(error)")
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
