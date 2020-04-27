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
}
