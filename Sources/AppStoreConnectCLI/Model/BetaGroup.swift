// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import FileSystem
import Model
import SwiftyTextTable

extension Model.BetaGroup: TableInfoProvider, ResultRenderable {

    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "App ID"),
            TextTableColumn(header: "App Bundle ID"),
            TextTableColumn(header: "App Name"),
            TextTableColumn(header: "Group Name"),
            TextTableColumn(header: "Is Internal"),
            TextTableColumn(header: "Public Link"),
            TextTableColumn(header: "Public Link Enabled"),
            TextTableColumn(header: "Public Link Limit"),
            TextTableColumn(header: "Public Link Limit Enabled"),
            TextTableColumn(header: "Creation Date"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        [
            app.id,
            app.bundleId ?? "",
            app.name ?? "",
            groupName ?? "",
            isInternal ?? "",
            publicLink ?? "",
            publicLinkEnabled ?? "",
            publicLinkLimit ?? "",
            publicLinkEnabled ?? "",
            creationDate ?? "",
        ]
    }
}

extension Model.BetaGroup {
    init(
        _ apiApp: AppStoreConnect_Swift_SDK.App,
        _ apiBetaGroup: AppStoreConnect_Swift_SDK.BetaGroup
    ) {
        self.init(
            app: Model.App(apiApp),
            groupName: apiBetaGroup.attributes?.name,
            isInternal: apiBetaGroup.attributes?.isInternalGroup,
            publicLink: apiBetaGroup.attributes?.publicLink,
            publicLinkEnabled: apiBetaGroup.attributes?.publicLinkEnabled,
            publicLinkLimit: apiBetaGroup.attributes?.publicLinkLimit,
            publicLinkLimitEnabled: apiBetaGroup.attributes?.publicLinkLimitEnabled,
            creationDate: apiBetaGroup.attributes?.createdDate?.formattedDate
        )
    }
}

extension FileSystem.BetaGroup: SyncResourceProcessable {

    var compareIdentity: String {
        id ?? ""
    }

    var syncResultText: String {
        groupName
    }

}

extension FileSystem.BetaGroup {
    init(
        _ apiBetaGroup: AppStoreConnect_Swift_SDK.BetaGroup,
        testersEmails: [String]
    ) {
        self.init(
            id: apiBetaGroup.id,
            groupName: (apiBetaGroup.attributes?.name)!,
            isInternal: apiBetaGroup.attributes?.isInternalGroup,
            publicLink: apiBetaGroup.attributes?.publicLink,
            publicLinkEnabled: apiBetaGroup.attributes?.publicLinkEnabled,
            publicLinkLimit: apiBetaGroup.attributes?.publicLinkLimit,
            publicLinkLimitEnabled: apiBetaGroup.attributes?.publicLinkLimitEnabled,
            creationDate: apiBetaGroup.attributes?.createdDate?.formattedDate,
            testers: testersEmails
        )
    }
}
