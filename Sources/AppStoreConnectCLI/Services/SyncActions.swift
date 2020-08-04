// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import FileSystem
import Model

class AppSyncActions {
    var app: Model.App
    var appTesters: [FileSystem.BetaTester]

    var appTestersSyncActions: [SyncAction<FileSystem.BetaTester>]
    var betaGroupSyncActions: [SyncAction<FileSystem.BetaGroup>]

    var testerInGroupsAction: [BetaTestersInGroupActions]

    init(
        app: Model.App,
        appTesters: [FileSystem.BetaTester],
        appTestersSyncActions: [SyncAction<FileSystem.BetaTester>],
        betaGroupSyncActions: [SyncAction<FileSystem.BetaGroup>],
        testerInGroupsAction: [BetaTestersInGroupActions]
    ) {
        self.app = app
        self.appTesters = appTesters
        self.appTestersSyncActions = appTestersSyncActions
        self.betaGroupSyncActions = betaGroupSyncActions
        self.testerInGroupsAction = testerInGroupsAction
    }
}

struct BetaTestersInGroupActions {
    let betaGroup: FileSystem.BetaGroup
    let testerActions: [SyncAction<FileSystem.BetaGroup.EmailAddress>]
}

extension SyncAction where T == FileSystem.BetaGroup {
    func render(dryRun: Bool) {
        switch self {
        case .create, .delete, .update:
            SyncResultRenderer<FileSystem.BetaGroup>().render(self, isDryRun: dryRun)
        }
    }
}

extension SyncAction where T == FileSystem.BetaTester {
    func render(dryRun: Bool) {
        switch self {
        case .delete:
            SyncResultRenderer<FileSystem.BetaTester>().render(self, isDryRun: dryRun)
        default:
            return
        }
    }
}

extension SyncAction where T == FileSystem.BetaGroup.EmailAddress {
    func render(dryRun: Bool) {
        switch self {
        case .create, .delete:
            SyncResultRenderer<FileSystem.BetaGroup.EmailAddress>().render(self, isDryRun: dryRun)
        default:
            return
        }
    }
}
