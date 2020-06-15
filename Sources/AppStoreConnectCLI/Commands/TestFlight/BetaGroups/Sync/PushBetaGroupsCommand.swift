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

        // Sync Beta Testers
        let localGroupWithTesters = try resourceProcessor.readGroupAndTesters()

        try localGroupWithTesters.forEach {
            let localGroupId = $0.betaGroup.id
            let localTesters = $0.testers

            let serverTesters = serverGroupsWithTesters.first {
                $0.betaGroup.id == localGroupId
            }?.testers ?? []

            let testerStrategies = SyncResourceComparator(
                    localResources: localTesters,
                    serverResources: serverTesters
                )
                .compare()

            let renderer = Renderers.SyncResultRenderer<BetaTester>()

            if dryRun {
                renderer.render(testerStrategies, isDryRun: true)
            } else {
                let renderer = Renderers.SyncResultRenderer<BetaTester>()

                try testerStrategies.forEach {
                    try syncTester(with: service, groupId: localGroupId!, strategies: $0)

                    renderer.render($0, isDryRun: false)
                }
            }
        }

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

            let betaGroupWithTesters = try service.pullBetaGroups()

            try resourceProcessor.write(groupsWithTesters: betaGroupWithTesters)
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
        groupId: String,
        strategies: SyncStrategy<BetaTester>
    ) throws {
        switch strategies {
        case .create(let tester):
            try service.inviteBetaTesterToGroups(
                firstName: tester.firstName,
                lastName: tester.lastName,
                email: tester.email!,
                groupIds: [groupId]
            )
        case .update:
            print("Update single beta tester is not supported.")
        case .delete(let tester):
            try service.removeTesterFromGroups(email: tester.email!, groupIds: [groupId])
        }
    }

}
