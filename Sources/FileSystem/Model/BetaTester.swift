// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

struct BetaTester: Codable, Hashable {

    var email: String
    var firstName: String
    var lastName: String

    init(
        email: String,
        firstName: String?,
        lastName: String?
    ) {
        self.email = email
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
    }

}
