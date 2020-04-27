// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Files

extension File {
    static func createFile(
        in folderName: String,
        named fileName: String,
        with content: String
    ) throws -> File {
        let folder = try Folder(path: folderName)

        return try folder.createFile(
            named: fileName,
            contents: Data(base64Encoded: content)
        )
    }

    static func getFolderAndFileName(from path: String) -> (String, String) {
        var folderName: String
        var fileName: String

        if path.contains("/") {
            let distanceToLast = path.distance(
                from: path.lastIndex(of: "/")!,
                to: path.endIndex
            )

            folderName = String(path.dropLast(distanceToLast))
            fileName = String(path.split(separator: "/").last!)
        } else {
            folderName = "."
            fileName = path
        }

        return (folderName, fileName)
    }
}
