// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct BetaTester: Codable, Hashable {

    var email: String
    var firstName: String
    var lastName: String

    enum CodingKeys: String, CodingKey, CaseIterable {
        case email = "Email"
        case firstName = "First Name"
        case lastName = "Last Name"
    }

    init(betaTester: Model.BetaTester) throws {
        try self.init(
            email: betaTester.email,
            firstName: betaTester.firstName,
            lastName: betaTester.lastName
        )
    }

    init(
        email: String?,
        firstName: String?,
        lastName: String?
    ) throws {
        let firstName = firstName ?? ""
        let lastName = lastName ?? ""

        guard let email = email else {
            throw ModelError.missingTesterEmail(firstName: firstName, lastName: lastName)
        }

        self.init(email: email, firstName: firstName, lastName: lastName)
    }

    init(
        email: String,
        firstName: String,
        lastName: String
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }

}
