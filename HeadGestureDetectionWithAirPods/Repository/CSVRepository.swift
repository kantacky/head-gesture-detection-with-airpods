//
//  CSVRepository.swift
//  HeadGestureDetectionWithAirPods
//
//  Created by Kanta Oikawa on 2025/08/19.
//

import Foundation

final actor CSVRepository {
    static func create(header: String, filename: String) throws -> FileHandle {
        let url = try buildDocumentURL(filename: filename)
        print("CSV file path: \(url.path)")
        FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        let file = try FileHandle(forWritingTo: url)
        guard let data = header.data(using: .utf8) else {
            throw CSVRepositoryError.failedToConvertStringToData
        }
        file.write(data)
        return file
    }

    static func write(_ row: String, to file: FileHandle) throws {
        guard let data = row.data(using: .utf8) else {
            throw CSVRepositoryError.failedToConvertStringToData
        }
        file.write(data)
    }

    static func close(file: FileHandle) throws {
        file.closeFile()
    }

    private static func buildDocumentURL(filename: String) throws -> URL {
        guard
            let url = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first
        else {
            throw CSVRepositoryError.failedToCreateURL
        }
        return url.appendingPathComponent("\(filename).csv")
    }
}
