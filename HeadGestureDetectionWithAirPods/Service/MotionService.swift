//
//  MotionService.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/09/11.
//

import CoreMotion
import Dependencies
import DependenciesMacros
import HeadphoneMotion

@DependencyClient
struct MotionService {
    var motionUpdates: @Sendable () throws -> AsyncThrowingStream<CMDeviceMotion, Error>
}

extension MotionService: DependencyKey {
    static let liveValue = {
        return MotionService(
            motionUpdates: {
                try HeadphoneMotionUpdate.updates()
            }
        )
    }()
}

extension MotionService: TestDependencyKey {
    static let testValue = MotionService()
}
