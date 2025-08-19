//
//  MotionLogCSVManager.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/19.
//

import Foundation

final actor MotionLogCSVManager {
    private var file: FileHandle?

    func createAndOpen(header: String) throws {
        let url = try Self.makeDocumentURL()
        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        let file = try FileHandle(forWritingTo: url)
        guard let data = header.data(using: .utf8) else {
            throw MotionLogCSVManagerError.failedToConvertStringToData
        }
        file.write(data)
        self.file = file
        print("File opened: \(url.absoluteString)")
    }

    func write(_ row: String) throws {
        guard let file else {
            throw MotionLogCSVManagerError.fileNotOpened
        }
        guard let data = row.data(using: .utf8) else {
            throw MotionLogCSVManagerError.failedToConvertStringToData
        }
        file.write(data)
    }

    func close() throws {
        guard let file else {
            throw MotionLogCSVManagerError.fileNotOpened
        }
        file.closeFile()
        self.file = nil
        print("File closed.")
    }

    private static func makeDocumentURL() throws -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw MotionLogCSVManagerError.failedToCreateURL
        }
        let formatter = ISO8601DateFormatter()
        let filename = formatter.string(from: Date()) + ".csv"
        return url.appendingPathComponent(filename)
    }
}
