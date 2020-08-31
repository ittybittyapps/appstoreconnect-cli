// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct BetaTester: Codable, Hashable {

    var email: String
    var firstName: String
    var lastName: String

    init?(betaTester: Model.BetaTester) {
        guard let email = betaTester.email else {
            return nil
        }

        self.email = email
        self.firstName = betaTester.firstName ?? ""
        self.lastName = betaTester.lastName ?? ""
    }

}
