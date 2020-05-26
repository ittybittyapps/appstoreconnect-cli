// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct Device: Codable, Equatable {
    public let udid: String?
    public let addedDate: Date?
    public let name: String?
    public let deviceClass: String?
    public let model: String?
    public let platform: String?
    public let status: String?

    public init(
        udid: String?,
        addedDate: Date?,
        name: String?,
        deviceClass: String?,
        model: String?,
        platform: String?,
        status: String?
    ) {
        self.udid = udid
        self.addedDate = addedDate
        self.name = name
        self.deviceClass = deviceClass
        self.model = model
        self.platform = platform
        self.status = status
    }
}
