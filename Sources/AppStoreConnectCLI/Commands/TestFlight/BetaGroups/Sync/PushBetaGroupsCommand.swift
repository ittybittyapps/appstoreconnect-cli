// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem
import Foundation
import struct Model.BetaGroup
import struct Model.BetaTester

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

        let serverGroupsWithTesters = try service.pullBetaGroups()
        let localGroups = try resourceProcessor.read()

        // Sync Beta Groups
        let strategies = SyncResourceComparator(
                localResources: localGroups,
                serverResources: serverGroupsWithTesters.map { $0.betaGroup }
            )
            .compare()

        let renderer = Renderers.SyncResultRenderer<BetaGroup>()

        if dryRun {
            renderer.render(strategies, isDryRun: true)
        } else {
            try strategies.forEach { (strategy: SyncStrategy) in
                try syncBetaGroup(strategy: strategy, with: service)
                renderer.render(strategy, isDryRun: false)
            }
        }

        // Sync Beta Testers
        let localGroupWithTesters = try resourceProcessor.readGroupAndTesters()

        try localGroupWithTesters.forEach {
            let localGroup = $0.betaGroup
            let localTesters = $0.testers

            let serverTesters = serverGroupsWithTesters.first {
                $0.betaGroup.id == localGroup.id
            }?.testers ?? []

            let testerStrategies = SyncResourceComparator(
                    localResources: localTesters,
                    serverResources: serverTesters
                )
                .compare()

            let renderer = Renderers.SyncResultRenderer<BetaTester>()

            if testerStrategies.count > 0 {
                print("\(localGroup.groupName): ")
            }

            if dryRun {
                renderer.render(testerStrategies, isDryRun: true)
            } else {
                try testerStrategies.forEach {
                    try syncTester(with: service,
                                   bundleId: localGroup.app.bundleId!,
                                   groupName: localGroup.groupName,
                                   strategies: $0)

                    renderer.render($0, isDryRun: false)
                }
            }
        }

        // After all operations, sync group and testers
        if !dryRun {
            try resourceProcessor.write(groupsWithTesters: try service.pullBetaGroups())
        }
    }

    func syncBetaGroup(
        strategy: SyncStrategy<BetaGroup>,
        with service: AppStoreConnectService
    ) throws {
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
    }

    func syncTester(
        with service: AppStoreConnectService,
        bundleId: String,
        groupName: String,
        strategies: SyncStrategy<BetaTester>
    ) throws {
        switch strategies {
        case .create(let tester):
            _ = try service.inviteBetaTesterToGroups(
                firstName: tester.firstName,
                lastName: tester.lastName,
                email: tester.email!,
                bundleId: bundleId,
                groupNames: [groupName]
            )
        case .update:
            print("Update single beta tester is not supported.")
        case .delete(let tester):
            try service.removeTesterFromGroups(email: tester.email!, groupNames: [groupName])
        }
    }

}
