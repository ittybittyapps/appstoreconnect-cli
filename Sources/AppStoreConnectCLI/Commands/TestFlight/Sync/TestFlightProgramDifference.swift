// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct TestFlightProgramDifference {

    enum Change {
        case addBetaGroup(BetaGroup)
        case removeBetaGroup(BetaGroup)
        case addBetaTesterToApps(BetaTester, [App])
        case removeBetaTesterFromApps(BetaTester, [App])
        case addBetaTesterToGroups(BetaTester, [BetaGroup])
        case removeBetaTesterFromGroups(BetaTester, [BetaGroup])

        var description: String {

            let operation: String = {
                switch self {
                case .addBetaGroup, .addBetaTesterToGroups, .addBetaTesterToApps:
                    return "added to"
                case .removeBetaGroup, .removeBetaTesterFromGroups, .removeBetaTesterFromApps:
                    return "removed from"
                }
            }()

            switch self {
            case .addBetaGroup(let betaGroup), .removeBetaGroup(let betaGroup):
                let name = betaGroup.groupName ?? ""
                let bundleId = betaGroup.app?.bundleId ?? ""

                return "Beta Group named: \(name) will be \(operation) app: \(bundleId)"

            case .addBetaTesterToApps(let betaTester, let apps),
                 .removeBetaTesterFromApps(let betaTester, let apps):
                let email = betaTester.email ?? ""
                let bundleIds = apps.compactMap(\.bundleId).joined(separator: ", ")

                return "Beta Tester with email: \(email) " +
                    "will be \(operation) apps: \(bundleIds)"

            case .addBetaTesterToGroups(let betaTester, let betaGroups),
                 .removeBetaTesterFromGroups(let betaTester, let betaGroups):
                let email = betaTester.email ?? ""
                let groupNames = betaGroups.compactMap(\.groupName).joined(separator: ", ")
                let bundleIds = betaGroups.compactMap(\.app?.bundleId).joined(separator: ", ")

                return "Beta Tester with email: \(email) " +
                    "will be \(operation) groups: \(groupNames) " +
                    "in apps: \(bundleIds)"
            }
        }
    }

    let changes: [Change]

    init(local: TestFlightProgram, remote: TestFlightProgram) {
        var changes: [Change] = []

        // Groups
        let localGroups = local.groups
        let groupsToAdd: [BetaGroup] = localGroups.filter { $0.id == nil }
        changes += groupsToAdd.map(Change.addBetaGroup)

        let localGroupIds = localGroups.map(\.id)
        let groupsToRemove: [BetaGroup] = remote.groups
            .filter { group in localGroupIds.contains(group.id) == false }
        changes += groupsToRemove.map(Change.removeBetaGroup)

        // Testers
        let newTesters = local.testers.filter { !remote.testers.map(\.email).contains($0.email) }

        changes += newTesters.map { betaTester -> Change in
            betaTester.betaGroups.isEmpty
                ? .addBetaTesterToApps(betaTester, betaTester.apps)
                : .addBetaTesterToGroups(betaTester, betaTester.betaGroups)
        }

        for remoteTester in remote.testers {
            let remoteApps = remoteTester.apps
            let remoteBetaGroups = remoteTester.betaGroups

            if let localTester = local.testers.first(where: { $0.email == remoteTester.email }) {
                let appsToAdd = localTester.apps.filter { app in
                    let appIds = remoteApps.map(\.id) + remoteBetaGroups.compactMap(\.app?.id)
                    return appIds.contains(app.id) == false
                }
                let addToApps = Change.addBetaTesterToApps(localTester, appsToAdd)
                changes += appsToAdd.isNotEmpty ? [addToApps] : []

                let groupsToAdd = localTester.betaGroups
                    .filter { !remoteBetaGroups.map(\.id).contains($0.id) }
                let addToGroups = Change.addBetaTesterToGroups(localTester, groupsToAdd)
                changes += groupsToAdd.isNotEmpty ? [addToGroups] : []

                let groupsToRemove = remoteBetaGroups
                    .filter { !localTester.betaGroups.map(\.id).contains($0.id) }
                let removeFromGroups = Change.removeBetaTesterFromGroups(localTester, groupsToRemove)
                changes += groupsToRemove.isNotEmpty ? [removeFromGroups] : []
            } else if remoteBetaGroups.isNotEmpty {
                changes.append(.removeBetaTesterFromGroups(remoteTester, remoteBetaGroups))
            }
        }

        self.changes = changes
    }

}
