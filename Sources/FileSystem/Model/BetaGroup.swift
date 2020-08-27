// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

struct BetaGroup: Codable, Equatable {

    typealias EmailAddress = String

    var id: String?
    var groupName: String
    var isInternal: Bool?
    var publicLink: String?
    var publicLinkEnabled: Bool?
    var publicLinkLimit: Int?
    var publicLinkLimitEnabled: Bool?
    var creationDate: String?
    var testers: [EmailAddress]

}
