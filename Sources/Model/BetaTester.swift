// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BetaTester: Codable, Equatable {

    public var email: String?
    public var firstName: String?
    public var lastName: String?
    public var inviteType: String?
    public var betaGroups: [BetaGroup]
    public var apps: [App]

    public init(
        email: String?,
        firstName: String?,
        lastName: String?,
        inviteType: String?,
        betaGroups: [BetaGroup]?,
        apps: [App]?
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.inviteType = inviteType
        self.betaGroups = betaGroups ?? []
        self.apps = apps ?? []
    }

}
