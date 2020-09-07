// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem
import Model

struct TestFlightPushCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "push",
        abstract: "Push local TestFlight configuration to the remote API."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/apps",
        help: "Path to read in the TestFlight configuration."
    ) var inputPath: String

    enum SyncAction {

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

    func run() throws {
        let localTestFlightProgram = try FileSystem.readTestFlightConfiguration(from: inputPath)

        let service = try makeService()
        let remoteTestFlightProgram = try service.getTestFlightProgram()

        // TODO: Compare local and remote Program
        var actions: [SyncAction] = []

        let localGroups = localTestFlightProgram.groups
        let groupsToAdd: [BetaGroup] = localGroups.filter { $0.id == nil }
        actions += groupsToAdd.map(SyncAction.addBetaGroup)

        let localGroupIds = localGroups.map(\.id)
        let groupsToRemove: [BetaGroup] = remoteTestFlightProgram.groups
            .filter { group in localGroupIds.contains(group.id) == false }
        actions += groupsToRemove.map(SyncAction.removeBetaGroup)

        actions.forEach { print($0.description) }

        // TODO: Push the testflight program to the API

        throw CommandError.unimplemented
    }

}
