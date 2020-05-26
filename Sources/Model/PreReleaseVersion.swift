// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct PreReleaseVersion: Codable, Equatable {
    public let app: App?
    public let platform: String?
    public let version: String?

    public init(
        app: App?,
        platform: String?,
        version: String?
    ) {
        self.app = app
        self.platform = platform
        self.version = version
    }
}
