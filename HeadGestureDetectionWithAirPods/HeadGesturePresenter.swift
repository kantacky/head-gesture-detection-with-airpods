//
//  HeadGesturePresenter.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import CoreMotion
import Observation

@MainActor
@Observable
final class HeadGesturePresenter {
    struct State {
        var motion: CMDeviceMotion?
        var startingPose: CMAttitude?
        var currentPose: CMAttitude?
    }

    enum Action {
        case onAppear
        case onDisappear
        case onResetStartingPoseButton
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
        switch action {
        case .onAppear:
            do {
                state.startingPose = try headphoneMotionManager.getCurrentPose()
            } catch {
                print("Error getting initial pose: \(error)")
            }
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
                    }
                } catch {
                    print("Error starting tracking: \(error)")
                }
            }

        case .onDisappear:
            trackingTask?.cancel()
            headphoneMotionManager.stopTracking()

        case .onResetStartingPoseButton:
            state.startingPose = nil
        }
    }
}
