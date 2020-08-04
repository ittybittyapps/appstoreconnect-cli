// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import struct FileSystem.TestFlightConfiguration
import struct FileSystem.BetaGroup
import struct FileSystem.BetaTester
import Foundation
import Model

struct TestFlightPushCommand: CommonParsableCommand {

    static var configuration =  CommandConfiguration(
        commandName: "push",
        abstract: "Push the local configuration to TestFlight."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/apps",
        help: "Path to the folder containing the TestFlight configuration."
    )
    var inputPath: String

    @Option(
        parsing: .upToNextOption,
        help: "Array of bundle IDs that uniquely identifies the apps that you would like to sync."
    )
    var bundleIds: [String]

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        let service = try makeService()

        print("Loading local TestFlight configurations...")
        let localConfigurations = try [TestFlightConfiguration](from: inputPath, with: bundleIds)
        print("Loading completed.")

        print("\nLoading server TestFlight configurations...")
        let serverConfigurations = try service.pullTestFlightConfigurations(with: bundleIds)
        print("Loading completed.")

        let actions = compare(
            serverConfigurations: serverConfigurations,
            with: localConfigurations
        )

        if dryRun {
            render(actions: actions)
        } else {
            try process(actions: actions, with: service)

            print("\nRefreshing local configurations...")
            try service.pullTestFlightConfigurations().save(in: inputPath)
            print("Refreshing completed.")
        }
    }

    func render(actions: [AppSyncActions]) {
        print("\n'Dry Run' mode activated, changes will not be applied. ")

        actions.forEach { action in
            print("\n\(action.app.name ?? ""): ")

            // 1. app testers
            if action.appTestersSyncActions.isNotEmpty {
                print("\n- Testers in App: ")
                action.appTestersSyncActions.forEach { $0.render(dryRun: dryRun) }
            }

            // 2. BetaGroups in App
            if action.betaGroupSyncActions.isNotEmpty {
                print("\n- BetaGroups in App: ")
                action.betaGroupSyncActions.forEach {
                    $0.render(dryRun: dryRun)

                    if case .create(let betagroup) = $0 {
                        action.testerInGroupsAction
                            .append(
                                .init(
                                    betaGroup: betagroup,
                                    testerActions: betagroup.testers.map {
                                        SyncAction<BetaGroup.EmailAddress>.create($0)
                                    }
                                )
                            )
                    }
                }
            }

            // 3. Testers in BetaGroup
            if action.testerInGroupsAction.isNotEmpty {
                print("\n- Testers In Beta Group: ")
                action.testerInGroupsAction.forEach {
                    if $0.testerActions.isNotEmpty {
                        print("\($0.betaGroup.groupName):")
                        $0.testerActions.forEach { $0.render(dryRun: dryRun) }
                    }
                }
            }
        }
    }

    private func process(actions: [AppSyncActions], with service: AppStoreConnectService) throws {
        try actions.forEach { appAction in
            print("\n\(appAction.app.name ?? ""): ")

            var appAction = appAction

            // 1. app testers
            try processAppTesterActions(
                appAction.appTestersSyncActions,
                appId: appAction.app.id,
                service: service
            )

            // 2. beta groups in app
            try processBetagroupsActions(
                appAction.betaGroupSyncActions,
                appId: appAction.app.id,
                appAction: &appAction,
                service: service
            )

            // 3. testers in beta group
            if appAction.testerInGroupsAction.isNotEmpty {
                print("\n- Testers In Beta Group: ")
                try appAction.testerInGroupsAction.forEach {
                    print("\($0.betaGroup.groupName): ")
                    try processTestersInBetaGroupActions(
                        $0.testerActions,
                        betagroupId: $0.betaGroup.id!,
                        appTesters: appAction.appTesters,
                        service: service
                    )
                }
            }
        }
    }

    private func compare(
        serverConfigurations: [TestFlightConfiguration],
        with localConfigurations: [TestFlightConfiguration]
    ) -> [AppSyncActions] {
        return serverConfigurations.compactMap { serverConfiguration in
            guard
                let localConfiguration = localConfigurations
                    .first(where: { $0.app.id == serverConfiguration.app.id }) else {
                return nil
            }

            let appTesterSyncActions = SyncResourceComparator(
                localResources: localConfiguration.testers,
                serverResources: serverConfiguration.testers
            )
            .compare()

            let betaGroupSyncActions = SyncResourceComparator(
                localResources: localConfiguration.betagroups,
                serverResources: serverConfiguration.betagroups
            )
            .compare()

            let testerInGroupsAction = localConfiguration.betagroups.compactMap { localBetagroup -> BetaTestersInGroupActions?  in
                guard
                    let serverBetaGroup = serverConfiguration
                        .betagroups
                        .first(where: { $0.id == localBetagroup.id }) else {
                    return nil
                }

                let testerActions = SyncResourceComparator(
                    localResources: localBetagroup.testers,
                    serverResources: serverBetaGroup.testers
                )
                .compare()

                if testerActions.isEmpty { return nil }

                return BetaTestersInGroupActions(
                    betaGroup: localBetagroup,
                    testerActions: testerActions
                )
            }

            guard appTesterSyncActions.isNotEmpty ||
                    betaGroupSyncActions.isNotEmpty ||
                    testerInGroupsAction.isNotEmpty else {
                return nil
            }

            return AppSyncActions(
                app: localConfiguration.app,
                appTesters: localConfiguration.testers,
                appTestersSyncActions: appTesterSyncActions,
                betaGroupSyncActions: betaGroupSyncActions,
                testerInGroupsAction: testerInGroupsAction
            )
        }
    }

    func processAppTesterActions(
        _ actions: [SyncAction<BetaTester>],
        appId: String,
        service: AppStoreConnectService
    ) throws {
        let testersToRemoveActionsWithEmails = actions.compactMap { action ->
            (action: SyncAction<BetaTester>, email: String)? in
            if case .delete(let betaTesters) = action {
                return (action, betaTesters.email)
            }
            return nil
        }

        if testersToRemoveActionsWithEmails.isNotEmpty {
            print("\n- Testers in App: ")
            try service.removeTestersFromApp(testersEmails: testersToRemoveActionsWithEmails.map { $0.email }, appId: appId)

            testersToRemoveActionsWithEmails.map { $0.action }.forEach { $0.render(dryRun: dryRun) }
        }
    }

    func processBetagroupsActions(
        _ actions: [SyncAction<BetaGroup>],
        appId: String,
        appAction: inout AppSyncActions,
        service: AppStoreConnectService
    ) throws {
        if actions.isNotEmpty {
            print("\n- BetaGroups in App: ")

            try actions.forEach { action in
                switch action {
                case .create(let betagroup):
                    let newCreatedBetaGroup = try service.createBetaGroup(
                        appId: appId,
                        groupName: betagroup.groupName,
                        publicLinkEnabled: betagroup.publicLinkEnabled ?? false,
                        publicLinkLimit: betagroup.publicLinkLimit
                    )
                    action.render(dryRun: dryRun)

                    if betagroup.testers.isNotEmpty {
                        appAction.testerInGroupsAction
                            .append(
                                .init(
                                    betaGroup: newCreatedBetaGroup,
                                    testerActions: betagroup.testers.map {
                                        SyncAction<BetaGroup.EmailAddress>.create($0)
                                    }
                                )
                            )
                    }

                case .delete(let betagroup):
                    try service.deleteBetaGroup(with: betagroup.id!)
                    action.render(dryRun: dryRun)
                case .update(let betagroup):
                    try service.updateBetaGroup(betaGroup: betagroup)
                    action.render(dryRun: dryRun)
                }
            }
        }
    }

    func processTestersInBetaGroupActions(
        _ actions: [SyncAction<BetaGroup.EmailAddress>],
        betagroupId: String,
        appTesters: [BetaTester],
        service: AppStoreConnectService
    ) throws {
        let deletingEmailsWithStrategy: [(email: String, strategy: SyncAction<BetaGroup.EmailAddress>)] = actions
            .compactMap { action in
                if case .delete(let email) = action {
                    return (email, action)
                }
                return nil
            }

        if deletingEmailsWithStrategy.isNotEmpty {
            try service.removeTestersFromGroup(
                emails: deletingEmailsWithStrategy.map { $0.email },
                groupId: betagroupId
            )

            deletingEmailsWithStrategy.forEach { $0.strategy.render(dryRun: dryRun) }
        }

        let creatingTestersWithStrategy = actions
            .compactMap { (strategy: SyncAction<BetaGroup.EmailAddress>) ->
                (tester: BetaTester, strategy: SyncAction<BetaGroup.EmailAddress>)? in
                if case .create(let email) = strategy,
                   let betatester = appTesters.first(where: { $0.email == email }) {
                    return (betatester, strategy)
                }
                return nil
            }

        if creatingTestersWithStrategy.isNotEmpty {
            try service.inviteTestersToGroup(
                betaTesters: creatingTestersWithStrategy.map { $0.tester },
                groupId: betagroupId
            )

            creatingTestersWithStrategy.forEach { $0.strategy.render(dryRun: dryRun) }
        }
    }

}
