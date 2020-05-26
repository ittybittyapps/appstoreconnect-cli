// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct Profile: Codable, Equatable {
    public let name: String?
    public let platform: String?
    public let profileContent: String?
    public let uuid: String?
    public let createdDate: Date?
    public let profileState: String?
    public let profileType: String?
    public let expirationDate: Date?

    public init(
        name: String?,
        platform: String?,
        profileContent: String?,
        uuid: String?,
        createdDate: Date?,
        profileState: String?,
        profileType: String?,
        expirationDate: Date?
    ) {
        self.name = name
        self.platform = platform
        self.profileContent = profileContent
        self.uuid = uuid
        self.createdDate = createdDate
        self.profileState = profileState
        self.profileType = profileType
        self.expirationDate = expirationDate

    }
}
