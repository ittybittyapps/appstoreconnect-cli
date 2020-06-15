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

extension BetaTester: Hashable {

    public static func == (lhs: BetaTester, rhs: BetaTester) -> Bool {
        return lhs.email == rhs.email &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(email)
        hasher.combine(firstName)
        hasher.combine(lastName)
    }

}
