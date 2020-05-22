// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BundleId: Codable, Equatable {
    public let identifier: String?
    public let name: String?
    public let platform: String?
    public let seedId: String?

    public init(
        identifier: String?,
        name: String?,
        platform: String?,
        seedId: String?
    ) {
        self.identifier = identifier
        self.name = name
        self.platform = platform
        self.seedId = seedId
    }
}
