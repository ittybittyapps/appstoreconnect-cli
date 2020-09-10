// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

enum TestFlightProgramError: LocalizedError {

    case testerWithNoGroups(Model.BetaTester)

    var errorDescription: String? {
        switch self {
        case .testerWithNoGroups(let tester):
            let email = tester.email ?? ""
            let bundleIds = tester.apps.compactMap(\.bundleId).joined(separator: ", ")

            return "Tester with email: \(email) " +
                "being added to apps: \(bundleIds) " +
                "has not been added to any beta groups"
        }
    }

}

extension TestFlightProgram {

    init(configuration: TestFlightConfiguration) throws {
        var apps: [Model.App] = []
        var testersByEmail: [String: Model.BetaTester] = [:]
        var groups: [Model.BetaGroup] = []

        for appConfiguration in configuration.appConfigurations {
            let app = Model.App(app: appConfiguration.app)
            apps.append(app)

            let betaGroupModel = { Model.BetaGroup(app: app, betaGroup: $0) }
            groups += appConfiguration.betaGroups.map(betaGroupModel)

            for betaTester in appConfiguration.betaTesters {
                var tester = testersByEmail[betaTester.email] ?? .init(betaTester: betaTester)
                tester.apps.append(app)
                tester.betaGroups += appConfiguration.betaGroups
                    .filter { $0.testers.contains(betaTester.email) }
                    .map(betaGroupModel)
                testersByEmail[betaTester.email] = tester
            }
        }

        let testers = Array(testersByEmail.values)

        if let testerWithNoGroups = testers.first(where: { $0.betaGroups.isEmpty }) {
            throw TestFlightProgramError.testerWithNoGroups(testerWithNoGroups)
        }

        self.init(apps: apps, testers: testers, groups: groups)
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
