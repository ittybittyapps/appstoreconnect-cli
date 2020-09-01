// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public func writeConfiguration(
    apps: [Model.App],
    testers: [Model.BetaTester],
    groups: [Model.BetaGroup],
    to appsFolderPath: String
) throws {
    let groupsByApp = Dictionary(grouping: groups, by: \.app?.id)

    let configurations: [TestflightConfiguration] = try apps.map { app in
        var config = try TestflightConfiguration(app: App(model: app))

        config.betaTesters = testers
            .filter { tester in tester.apps.map(\.id).contains(app.id) }
            .compactMap(FileSystem.BetaTester.init)

        config.betaGroups = (groupsByApp[app.id] ?? []).map { betaGroup in
            FileSystem.BetaGroup(
                betaGroup: betaGroup,
                betaTesters: testers.filter { $0.betaGroups.map(\.id).contains(betaGroup.id) }
            )
        }

        return config
    }

    let processor = TestflightConfigurationProcessor(appsFolderPath: appsFolderPath)
    try processor.writeConfiguration(configurations: configurations)
}
