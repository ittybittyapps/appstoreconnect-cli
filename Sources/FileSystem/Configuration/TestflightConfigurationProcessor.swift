// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public struct TestflightConfigurationProcessor: ResourceWriter {

    let path: ResourcePath

    public init(path: ResourcePath) {
        self.path = path
    }

    private typealias AppConfiguration = TestflightConfiguration.AppConfiguration

    public func writeConfiguration(
        apps: [Model.App],
        testers: [Model.BetaTester],
        groups: [Model.BetaGroup]
    ) {
        var appConfigurations: [AppConfiguration] = []

        let groupsByApp = Dictionary(grouping: groups, by: \.app?.id)

        for app in apps {
            var appConfiguration = AppConfiguration(app: app)

            appConfiguration.betaTesters = testers
                .filter { tester in (tester.apps).map(\.id).contains(app.id) }
                .compactMap(FileSystem.BetaTester.init)

            appConfiguration.betaGroups = (groupsByApp[app.id] ?? []).map { betaGroup in
                FileSystem.BetaGroup(
                    betaGroup: betaGroup,
                    betaTesters: testers.filter { ($0.betaGroups).map(\.id).contains(betaGroup.id) }
                )
            }

            appConfigurations += [appConfiguration]
        }

        let configuration = TestflightConfiguration(appConfigurations: appConfigurations)
    }

}
