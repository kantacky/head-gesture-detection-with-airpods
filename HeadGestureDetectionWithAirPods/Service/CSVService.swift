//
//  CSVService.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/09/12.
//

import CoreMotion
import Dependencies
import DependenciesMacros

@DependencyClient
struct CSVService {
    var create: @Sendable (_ header: String, _ filename: String) throws -> FileHandle
    var write: @Sendable (_ row: String, _ file: FileHandle) throws -> Void
    var close: @Sendable (_ file: FileHandle) throws -> Void
}

extension CSVService: DependencyKey {
    static let liveValue = CSVService(
        create: { header, filename in
            try CSVRepository.create(header: header, filename: filename)
        },
        write: { row, file in
            try CSVRepository.write(row, to: file)
        },
        close: { file in
            try CSVRepository.close(file: file)
        }
    )
}

extension CSVService: TestDependencyKey {
    static let testValue = CSVService()
}
