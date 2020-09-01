// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public func writeConfiguration(
    apps: [Model.App],
    testers: [Model.BetaTester],
    groups: [Model.BetaGroup],
    to appsFolderPath: String
) throws {
    let configuration = try TestflightConfiguration(apps: apps, testers: testers, groups: groups)

    let processor = TestflightConfigurationProcessor(appsFolderPath: appsFolderPath)
    try processor.writeConfiguration(configuration)
}
