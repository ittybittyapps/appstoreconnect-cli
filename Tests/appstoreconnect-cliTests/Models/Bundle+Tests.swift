// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension Bundle {
    static let tests: Bundle =
        Bundle(url: URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures.bundle"))!
}
