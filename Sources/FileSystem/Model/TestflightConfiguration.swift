// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct TestflightConfiguration {

    var appConfigurations: [AppConfiguration]

    init(
        apps: [Model.App],
        testers: [Model.BetaTester],
        groups: [Model.BetaGroup]
    ) throws {
        let groupsByApp = Dictionary(grouping: groups, by: \.app?.id)

        appConfigurations = try apps.map { app in
            var config = try AppConfiguration(app: App(model: app))

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
    }

    struct AppConfiguration {

        var app: App
        var betaTesters: [BetaTester] = []
        var betaGroups: [BetaGroup] = []

    }

}
