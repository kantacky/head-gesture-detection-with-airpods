//
//  HeadGesturePresenter.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import AsyncAlgorithms
import CoreMotion
import Dependencies
import Observation
import RealityKit
import SwiftUI

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
        var motions: [CMDeviceMotion] = []
        var currentGesture: Gesture = .idle
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
    @Dependency(HeadGesturePredictionService.self) private var headGesturePredictionService
    @ObservationIgnored
    private var trackingTask: Task<Void, Never>?
    @ObservationIgnored
    private var gesturePredictionTimerTask: Task<Void, Never>?

    deinit {
        Task { [weak self] in
            await self?.trackingTask?.cancel()
            await self?.gesturePredictionTimerTask?.cancel()
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
                    if let csvFile = state.csvFile {
                        saveMotionLog(file: csvFile, motion: motion)
                    }
                    state.motions.append(motion)
                    if state.motions.count > 100 {
                        state.motions.removeFirst()
                    }
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
        let timer = AsyncTimerSequence(
            interval: .milliseconds(100),
            clock: .continuous
        )
        gesturePredictionTimerTask = Task {
            for await _ in timer {
                do {
                    if state.motions.count != 100 {
                        continue
                    }
                    let gesture = try await headGesturePredictionService.predict(motions: state.motions)
                    if state.currentGesture != gesture {
                        scroll(gesture: gesture)
                    }
                    state.currentGesture = gesture
                } catch {
                    print("Failed to predict gesture: \(error)")
                }
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

    func scroll(gesture: Gesture) {
        var scrollPosition = state.scrollPosition ?? 0
        switch gesture {
        case .idle:
            break
        case .left:
            scrollPosition += 1
        case .right:
            scrollPosition -= 1
        }
        withAnimation {
            state.scrollPosition = max(0, scrollPosition)
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
