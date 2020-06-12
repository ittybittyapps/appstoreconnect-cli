// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem
import Foundation
import struct Model.BetaGroup

struct PushBetaGroupsCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "push",
        abstract: "Push local beta group config files to server, update server beta groups"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/betagroups",
        help: "Path to the Folder containing the information about beta groups. (default: './config/betagroups')"
    ) var inputPath: String

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        let service = try makeService()

        let resourceProcessor = BetaGroupProcessor(path: .folder(path: inputPath))

        let serverGroups = Set(try service.pullBetaGroups().map{ $0.betaGroup })
        let localGroups = Set(try resourceProcessor.read())

        let strategies = compareGroups(
            localGroups: localGroups,
            serverGroups: serverGroups
        )

        let renderer = Renderers.SyncResultRenderer<BetaGroup>()

        if dryRun {
            renderer.render(strategies, isDryRun: true)
        } else {
            try strategies.forEach { (strategy: SyncStrategy) in
                switch strategy {
                case .create(let group):
                    _ = try service.createBetaGroup(
                        appBundleId: group.app.bundleId!,
                        groupName: group.groupName,
                        publicLinkEnabled: group.publicLinkEnabled ?? false,
                        publicLinkLimit: group.publicLinkLimit
                    )
                case .delete(let group):
                    try service.deleteBetaGroup(with: group.id!)
                case .update(let group):
                    try service.updateBetaGroup(betaGroup: group)
                }

                renderer.render(strategy, isDryRun: false)
            }

            let betaGroupWithTesters = try service.pullBetaGroups()

            try resourceProcessor.write(groupsWithTesters: betaGroupWithTesters)
        }
    }

    func compareGroups(localGroups: Set<BetaGroup>, serverGroups: Set<BetaGroup>) -> [SyncStrategy<BetaGroup>] {
        var strategies: [SyncStrategy<BetaGroup>] = []

        let groupToCreate = localGroups.subtracting(serverGroups)
        let groupToDelete = serverGroups.subtracting(localGroups)

        groupToDelete.forEach { group in
            if !localGroups.contains(where: { group.id == $0.id }) {
                strategies.append(.delete(group))
            }
        }

        groupToCreate.forEach { group in
            serverGroups.contains(where: { group.id == $0.id })
                ? strategies.append(.update(group))
                : strategies.append(.create(group))
        }

        return strategies
    }

}
