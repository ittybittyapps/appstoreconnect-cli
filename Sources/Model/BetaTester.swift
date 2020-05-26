// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BetaTester: Codable, Equatable {
    public let email: String?
    public let firstName: String?
    public let lastName: String?
    public let inviteType: String?
    public let betaGroups: [String]?
    public let apps: [String]?

    public init(
        email: String?,
        firstName: String?,
        lastName: String?,
        inviteType: String?,
        betaGroups: [String]?,
        apps: [String]?
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.inviteType = inviteType
        self.betaGroups = betaGroups
        self.apps = apps
    }
}
