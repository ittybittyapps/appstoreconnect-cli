// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct BetaGroup: Codable, Equatable {

    typealias EmailAddress = String

    var id: String?
    var groupName: String
    var testers: [EmailAddress]

    init(betaGroup: Model.BetaGroup, betaTesters: [Model.BetaTester]) {
        id = betaGroup.id
        groupName = betaGroup.groupName ?? ""
        testers = betaTesters.compactMap(\.email)
    }

}
