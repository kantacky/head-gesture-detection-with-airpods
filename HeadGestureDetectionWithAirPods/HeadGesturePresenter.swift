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
        var currentPose: CMAttitude?
    }

    enum Action {
        case onAppear
        case onDisappear
        case onResetStartingPoseButton
    }

    private(set) var state = State()
    private var startingPose: CMAttitude?
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
            startingPose = headphoneMotionManager.getCurrentPose()
            trackingTask = Task {
                do {
                    for await pose in try headphoneMotionManager.startTracking() {
                        if let startingPose {
                            pose.multiply(byInverseOf: startingPose)
                        }
                        state.currentPose = pose
                    }
                } catch {
                    print("Error starting tracking: \(error)")
                }
            }

        case .onDisappear:
            trackingTask?.cancel()
            headphoneMotionManager.stopTracking()

        case .onResetStartingPoseButton:
            startingPose = headphoneMotionManager.getCurrentPose()
            if let startingPose {
                state.currentPose?.multiply(byInverseOf: startingPose)
            }
        }
    }
}
