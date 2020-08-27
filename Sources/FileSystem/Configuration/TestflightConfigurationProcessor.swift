// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public struct TestflightConfigurationProcessor: ResourceWriter {

    let path: ResourcePath

    public init(path: ResourcePath) {
        self.path = path
    }

    public func writeConfiguration(
        apps: [Model.App],
        testers: [Model.BetaTester],
        groups: [Model.BetaGroup]
    ) {
        // TODO: Convert models to a TestflightConfiguration and write it to disk
    }

}
