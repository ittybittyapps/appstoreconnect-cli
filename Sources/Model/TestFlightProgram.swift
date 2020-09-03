// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

/// Aggregated model data representing the a TestFlight Beta Program (Apps, Testers and Groups)
public struct TestFlightProgram {

    public var apps: [App]
    public var testers: [BetaTester]
    public var groups: [BetaGroup]

    public init(
        apps: [App],
        testers: [BetaTester],
        groups: [BetaGroup]
    ) {
        self.apps = apps
        self.testers = testers
        self.groups = groups
    }

}
