// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

struct TestFlightProgramDifference {

    enum Change {
        case addBetaGroup(BetaGroup)
        case removeBetaGroup(BetaGroup)
        case addBetaTester(BetaTester, toBetaGroups: [BetaGroup])
        case removeBetaTester(BetaTester, fromBetaGroups: [BetaGroup])

        var description: String {

            let operation: String = {
                switch self {
                case .addBetaGroup, .addBetaTester: return "added to"
                case .removeBetaGroup, .removeBetaTester: return "removed from"
                }
            }()

            switch self {
            case .addBetaGroup(let betaGroup), .removeBetaGroup(let betaGroup):
                let name = betaGroup.groupName ?? ""
                let bundleId = betaGroup.app?.bundleId ?? ""

                return "Beta group named: \(name) will be \(operation) app with bundleId: \(bundleId)"

            case .addBetaTester(let betaTester, let betaGroups),
                 .removeBetaTester(let betaTester, let betaGroups):
                let email = betaTester.email ?? ""
                let groupNames = betaGroups.map({ $0.groupName ?? "" }).joined(separator: ", ")

                return "Beta Tester with email: \(email) will be \(operation) groups: \(groupNames)"
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
        changes += newTesters.map { Change.addBetaTester($0, toBetaGroups: $0.betaGroups) }

        for remoteTester in remote.testers {
            if let localTester = local.testers.first(where: { $0.email == remoteTester.email }) {
                let groupsToAdd = localTester.betaGroups
                    .filter { !remoteTester.betaGroups.map(\.id).contains($0.id) }
                let addAction = Change.addBetaTester(localTester, toBetaGroups: groupsToAdd)
                changes += groupsToAdd.isNotEmpty ? [addAction] : []

                let groupsToRemove = remoteTester.betaGroups
                    .filter { !localTester.betaGroups.map(\.id).contains($0.id) }
                let removeAction = Change.removeBetaTester(localTester, fromBetaGroups: groupsToRemove)
                changes += groupsToRemove.isNotEmpty ? [removeAction] : []
            } else if remoteTester.betaGroups.isNotEmpty {
                changes.append(.removeBetaTester(remoteTester, fromBetaGroups: remoteTester.betaGroups))
            }
        }

        self.changes = changes
    }

}
