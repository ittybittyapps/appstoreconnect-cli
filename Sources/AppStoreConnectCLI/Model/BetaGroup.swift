// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.App
import struct Model.BetaGroup
import SwiftyTextTable

extension BetaGroup: TableInfoProvider, ResultRenderable {

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

extension BetaGroup {
    init(
        _ apiApp: AppStoreConnect_Swift_SDK.App,
        _ apiBetaGroup: AppStoreConnect_Swift_SDK.BetaGroup
    ) {
        self.init(
            id: apiBetaGroup.id,
            app: App(apiApp),
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
