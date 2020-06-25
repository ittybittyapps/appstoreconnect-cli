// Copyright 2020 Itty Bitty Apps Pty Ltd

import Files
import Foundation

extension Folder {

    // swiftlint:disable force_try
    static let tests: Folder = try! Folder(
        path: URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures.bundle").path
    )
}
