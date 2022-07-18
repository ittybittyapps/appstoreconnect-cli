// Copyright 2022 Itty Bitty Apps Pty Ltd

import Foundation

public struct UserInvitation: Codable, Equatable {
    public let username: String
    public let firstName: String?
    public let lastName: String?
    public let roles: [UserRole]
    public let provisioningAllowed: Bool
    public let allAppsVisible: Bool
    public let expirationDate: Date

    public init(
        username: String,
        firstName: String,
        lastName: String,
        roles: [UserRole],
        provisioningAllowed: Bool,
        allAppsVisible: Bool,
        expirationDate: Date
    ) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.roles = roles
        self.provisioningAllowed = provisioningAllowed
        self.allAppsVisible = allAppsVisible
        self.expirationDate = expirationDate
    }
}
