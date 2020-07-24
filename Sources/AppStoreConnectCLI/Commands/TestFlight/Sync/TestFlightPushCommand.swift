// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem
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

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        let service = try makeService()

        print("Loading local TestFlight configs... \n")

        let localConfigurations = try [TestFlightConfiguration](from: inputPath)

        print("Loading server TestFlight configs... \n")
        let serverConfigurations = try service.pullTestFlightConfigurations()

        let actions = compare(
            serverConfigurations: serverConfigurations,
            with: localConfigurations
        )

        if dryRun {
            render(actions: actions)
        } else {
            try process(actions: actions, with: service)

            print("Refreshing local configurations...")
            try service.pullTestFlightConfigurations().save(in: inputPath)
            print("Refreshing completed.")
        }
    }

    func render(actions: [AppSyncActions]) {
        print("'Dry Run' mode activated, changes will not be applied. ")

        actions.forEach {
            print("\n\($0.app.name ?? ""): ")

            // 1. app testers
            if $0.appTestersSyncActions.isNotEmpty {
                print("\n- Testers in App: ")
                $0.appTestersSyncActions.forEach { $0.render(dryRun: dryRun) }
            }

            // 2. BetaGroups in App
            if $0.betaGroupSyncActions.isNotEmpty {
                print("\n- BetaGroups in App: ")
                $0.betaGroupSyncActions.forEach { $0.render(dryRun: dryRun) }
            }

            // 3. Testers in BetaGroup
            if $0.testerInGroupsAction.isNotEmpty {
                print("\n- Testers In Beta Group: ")
                $0.testerInGroupsAction.forEach {
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
            var appAction = appAction

            print("\n\(appAction.app.name ?? ""): ")
            // 1. app testers
            if appAction.appTestersSyncActions.isNotEmpty {
                print("\n- Testers in App: ")
                try processAppTesterActions(
                    appAction.appTestersSyncActions,
                    appId: appAction.app.id,
                    service: service
                )
            }

            // 2. beta groups in app
            if appAction.betaGroupSyncActions.isNotEmpty {
                print("\n- BetaGroups in App: ")
                try processBetagroupsActions(
                    appAction.betaGroupSyncActions,
                    appId: appAction.app.id,
                    appAction: &appAction,
                    service: service
                )
            }

            // 3. testers in beta group
            if appAction.testerInGroupsAction.isNotEmpty {
                print("\n- Testers In Beta Group: ")
                try appAction.testerInGroupsAction.forEach {
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

            return AppSyncActions(
                app: localConfiguration.app,
                appTesters: localConfiguration.testers,
                appTestersSyncActions: appTesterSyncActions,
                betaGroupSyncActions: betaGroupSyncActions,
                testerInGroupsAction: testerInGroupsAction
            )
        }
    }

    func processAppTesterActions(_ actions: [SyncAction<FileSystem.BetaTester>], appId: String, service: AppStoreConnectService) throws {
        try actions.forEach { action in
            switch action {
            case .delete(let betatester):
                try service.removeTesterFromApp(testerEmail: betatester.email, appId: appId)
                action.render(dryRun: dryRun)
            default:
                return
            }
        }
    }

    func processBetagroupsActions(
        _ actions: [SyncAction<FileSystem.BetaGroup>],
        appId: String,
        appAction: inout AppSyncActions,
        service: AppStoreConnectService
    ) throws {
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
                                    SyncAction<FileSystem.BetaGroup.EmailAddress>.create($0)
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

    func processTestersInBetaGroupActions(
        _ actions: [SyncAction<FileSystem.BetaGroup.EmailAddress>],
        betagroupId: String,
        appTesters: [FileSystem.BetaTester],
        service: AppStoreConnectService
    ) throws {
        let deletingEmailsWithStrategy = actions
            .compactMap { (action: SyncAction<FileSystem.BetaGroup.EmailAddress>) ->
                (email: String, strategy: SyncAction<FileSystem.BetaGroup.EmailAddress>)? in
                if case .delete(let email) = action {
                    return (email, action)
                }
                return nil
            }

        try service.removeTestersFromGroup(
            emails: deletingEmailsWithStrategy.map { $0.email },
            groupId: betagroupId
        )

        deletingEmailsWithStrategy.forEach { $0.strategy.render(dryRun: dryRun) }

        let creatingTestersWithStrategy = actions
            .compactMap { (strategy: SyncAction<FileSystem.BetaGroup.EmailAddress>) ->
                (tester: FileSystem.BetaTester, strategy: SyncAction<FileSystem.BetaGroup.EmailAddress>)? in
                if case .create(let email) = strategy,
                   let betatester = appTesters.first(where: { $0.email == email }) {
                    return (betatester, strategy)
                }
                return nil
            }

        try creatingTestersWithStrategy.forEach {
            try service.inviteBetaTesterToGroups(
                email: $0.tester.email,
                groupId: betagroupId,
                firstName: $0.tester.firstName,
                lastName: $0.tester.lastName
            )

            $0.strategy.render(dryRun: dryRun)
        }

    }

}
