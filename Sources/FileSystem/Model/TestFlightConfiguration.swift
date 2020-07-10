// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public struct TestFlightConfiguration: Codable, Equatable {

    public let app: Model.App
    public let testers: [BetaTester]
    public let betagroups: [BetaGroup]

    public init(
        app: Model.App,
        testers: [BetaTester],
        betagroups: [BetaGroup]
    ) {
        self.app = app
        self.testers = testers
        self.betagroups = betagroups
    }

}
