// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

extension TestFlightProgram {

    init(configuration: TestFlightConfiguration) {
        var apps: [Model.App] = []
        var testers: [String: Model.BetaTester] = [:]
        var groups: [Model.BetaGroup] = []

        for appConfiguration in configuration.appConfigurations {
            let app = Model.App(app: appConfiguration.app)
            apps.append(app)

            let betaGroupModel = { Model.BetaGroup(app: app, betaGroup: $0) }
            groups += appConfiguration.betaGroups.map(betaGroupModel)

            for betaTester in appConfiguration.betaTesters {
                var tester = testers[betaTester.email] ?? Model.BetaTester(betaTester: betaTester)
                tester.apps.append(app)
                tester.betaGroups += appConfiguration.betaGroups
                    .filter { $0.testers.contains(betaTester.email) }
                    .map(betaGroupModel)
                testers[betaTester.email] = tester
            }
        }

        self.init(apps: apps, testers: Array(testers.values), groups: groups)
    }

}

private extension Model.App {

    init(app: App) {
        self.init(
            id: app.id,
            bundleId: app.bundleId,
            name: app.name,
            primaryLocale: app.primaryLocale,
            sku: app.sku
        )
    }

}

private extension Model.BetaTester {

    init(betaTester: BetaTester) {
        self.init(
            email: betaTester.email,
            firstName: betaTester.firstName,
            lastName: betaTester.lastName,
            inviteType: nil,
            betaGroups: [],
            apps: []
        )
    }

}

private extension Model.BetaGroup {

    init(app: Model.App, betaGroup: BetaGroup) {
        self.init(
            id: betaGroup.id,
            app: app,
            groupName: betaGroup.groupName,
            isInternal: nil,
            publicLink: nil,
            publicLinkEnabled: nil,
            publicLinkLimit: nil,
            publicLinkLimitEnabled: nil,
            creationDate: nil
        )
    }

}
