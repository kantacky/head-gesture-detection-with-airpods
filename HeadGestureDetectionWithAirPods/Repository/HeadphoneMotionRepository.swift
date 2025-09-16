//
//  HeadphoneMotionRepository.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/18.
//

@preconcurrency import CoreMotion

final class HeadphoneMotionRepository: NSObject, CMHeadphoneMotionManagerDelegate, Sendable {
    private let manager: CMHeadphoneMotionManager

    override init() {
        manager = CMHeadphoneMotionManager()
        super.init()
        manager.delegate = self
    }

    func startTracking(queue: OperationQueue? = .current) throws -> AsyncStream<CMDeviceMotion> {
        guard manager.isDeviceMotionAvailable else {
            throw HeadphoneMotionRepositoryError.deviceMotionNotAvailable
        }
        return AsyncStream { continuation in
            manager.startDeviceMotionUpdates(to: queue ?? .main) { motion, error in
                guard let motion else {
                    return
                }
                continuation.yield(motion)
            }
        }
    }

    func stopTracking() {
        manager.stopDeviceMotionUpdates()
    }
}

extension CMDeviceMotion: @retroactive @unchecked Sendable {
}
