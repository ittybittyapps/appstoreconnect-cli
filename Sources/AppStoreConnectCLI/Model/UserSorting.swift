// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

enum UserSorting: String, CaseIterable, Codable {
    case lastName = "lastname"
    case username = "username"
    case lastNameDesc = "-lastname"
    case usernameDesc = "-username"
}

extension UserSorting: ExpressibleByArgument {
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}
