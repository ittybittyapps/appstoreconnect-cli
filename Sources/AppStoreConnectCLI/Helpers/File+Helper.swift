// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Files

extension File {
    static func folderAndFilename(from path: String) -> (String, String) {
        let filePath: NSString = path as NSString
        
        return (filePath.deletingLastPathComponent, filePath.lastPathComponent)
    }
}
