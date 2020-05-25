// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct Certificate: Codable, Equatable {
    public let name: String?
    public let type: String?
    public let content: String?
    public let platform: String?
    public let expirationDate: Date?
    public let serialNumber: String?

    public init(
        name: String?,
        type: String?,
        content: String?,
        platform: String?,
        expirationDate: Date?,
        serialNumber: String?
    ) {
        self.name = name
        self.type = type
        self.content = content
        self.platform = platform
        self.expirationDate = expirationDate
        self.serialNumber = serialNumber
    }
}
