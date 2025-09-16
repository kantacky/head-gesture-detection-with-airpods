//
//  MotionService.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/09/11.
//

import CoreMotion
import Dependencies
import DependenciesMacros

@DependencyClient
struct MotionService {
    var startTracking: @Sendable () throws -> AsyncStream<CMDeviceMotion>
    var stopTracking: @Sendable () -> Void = {}
}

extension MotionService: DependencyKey {
    static let liveValue = {
        let repository = HeadphoneMotionRepository()
        return MotionService(
            startTracking: {
                try repository.startTracking()
            },
            stopTracking: {
                repository.stopTracking()
            }
        )
    }()
}

extension MotionService: TestDependencyKey {
    static let testValue = MotionService()
}
