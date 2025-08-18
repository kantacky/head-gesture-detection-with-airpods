//
//  HeadphoneMotionManager.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import CoreMotion
import Observation

@Observable
final class HeadphoneMotionManager: NSObject, CMHeadphoneMotionManagerDelegate {
    private let manager: CMHeadphoneMotionManager
    private var startingPose: CMAttitude?
    private(set) var currentPose: CMAttitude?

    override init() {
        manager = CMHeadphoneMotionManager()
        super.init()
        manager.delegate = self
    }

    func startTracking(queue: OperationQueue? = .current) {
        guard manager.isDeviceMotionAvailable else {
            print("Device motion is not available.")
            return
        }
        resetStartingPose()
        manager.startDeviceMotionUpdates(to: queue ?? .main) { [weak self] motion, error in
            guard let motion else {
                return
            }
            let currentPose = motion.attitude
            if let startingPose = self?.startingPose {
                currentPose.multiply(byInverseOf: startingPose)
            }
            self?.currentPose = currentPose
        }
    }

    func stopTracking() {
        manager.stopDeviceMotionUpdates()
        startingPose = nil
        currentPose = nil
    }

    func resetStartingPose() {
        startingPose = manager.deviceMotion?.attitude
    }

    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
    }

    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
    }
}
