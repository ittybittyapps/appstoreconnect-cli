// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BetaTester: Codable, Hashable {
    public var email: String
    public var firstName: String
    public var lastName: String

    public init(
        email: String,
        firstName: String?,
        lastName: String?
    ) {
        self.email = email
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
    }
}
