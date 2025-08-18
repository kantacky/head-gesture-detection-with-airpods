//
//  HeadphoneMotionManager.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

import CoreMotion

final class HeadphoneMotionManager: NSObject, CMHeadphoneMotionManagerDelegate {
    private let manager: CMHeadphoneMotionManager

    override init() {
        manager = CMHeadphoneMotionManager()
        super.init()
        manager.delegate = self
    }

    func startTracking(queue: OperationQueue? = .current) throws -> AsyncStream<CMAttitude> {
        guard manager.isDeviceMotionAvailable else {
            throw HeadphoneMotionManagerError.deviceMotionNotAvailable
        }
        return AsyncStream { continuation in
            manager.startDeviceMotionUpdates(to: queue ?? .main) { motion, error in
                guard let motion else {
                    return
                }
                continuation.yield(motion.attitude)
            }
        }
    }

    func stopTracking() {
        manager.stopDeviceMotionUpdates()
    }

    func getCurrentPose() -> CMAttitude? {
        manager.deviceMotion?.attitude
    }

    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
    }

    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
    }
}

extension CMAttitude: @retroactive @unchecked Sendable {
}
