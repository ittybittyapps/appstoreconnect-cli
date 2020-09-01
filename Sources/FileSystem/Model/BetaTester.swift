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

    init?(betaTester: Model.BetaTester) {
        guard let email = betaTester.email else {
            return nil
        }

        self.email = email
        self.firstName = betaTester.firstName ?? ""
        self.lastName = betaTester.lastName ?? ""
    }

}
