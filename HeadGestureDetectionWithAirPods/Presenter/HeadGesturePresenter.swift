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
        var isLogging: Bool {
            csvFile != nil
        }
        fileprivate var csvFile: FileHandle?
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
            onLoggingButtonTapped()

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
                    guard let csvFile = state.csvFile else {
                        return
                    }
                    saveMotionLog(file: csvFile, motion: motion)
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

    func onLoggingButtonTapped() {
        if let csvFile = state.csvFile {
            try? csvService.close(csvFile)
            state.csvFile = nil
            return
        }
        do {
            state.csvFile = try csvService.create(
                header: MotionLogCSVRow.csvHeaderString,
                filename: DateFormatter.fileName.string(from: .now)
            )
        } catch {
            print("Failed to create motion log CSV file: \(error)")
        }
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

    func saveMotionLog(file: FileHandle, motion: CMDeviceMotion) {
        do {
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
