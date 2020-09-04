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
            switch self {
            case .addBetaGroup(let betaGroup):
                let groupName = betaGroup.groupName ?? "Unnamed BetaGroup"
                let bundleId = betaGroup.app?.bundleId ?? ""
                return "Beta group named: \(groupName) will be added to app with bundleId: \(bundleId)"
            case .removeBetaGroup(let betaGroup):
                let groupName = betaGroup.groupName ?? "Unnamed BetaGroup"
                let bundleId = betaGroup.app?.bundleId ?? ""
                return "Beta group named: \(groupName) will be removed from app with bundleId: \(bundleId)"
            case .addBetaTester(let betaTester, let betaGroups):
                return ""
            case .removeBetaTester(let betaTester, let betaGroups):
                return ""
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
