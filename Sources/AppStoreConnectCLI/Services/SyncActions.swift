// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import FileSystem
import Model

struct AppSyncActions {
    let app: Model.App
    let appTesters: [FileSystem.BetaTester]

    let appTestersSyncActions: [SyncAction<FileSystem.BetaTester>]
    let betaGroupSyncActions: [SyncAction<FileSystem.BetaGroup>]

    let testerInGroupsAction: [BetaTestersInGroupActions]
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
