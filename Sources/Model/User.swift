// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct User: Codable, Equatable {
    public let username: String
    public let firstName: String
    public let lastName: String
    public let roles: [String]
    public let provisioningAllowed: Bool
    public let allAppsVisible: Bool
    public let visibleApps: [String]?

    public init(
        username: String,
        firstName: String,
        lastName: String,
        roles: [String],
        provisioningAllowed: Bool,
        allAppsVisible: Bool,
        visibleApps: [String]?
    ) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.roles = roles
        self.provisioningAllowed = provisioningAllowed
        self.allAppsVisible = allAppsVisible
        self.visibleApps = visibleApps
    }
}
