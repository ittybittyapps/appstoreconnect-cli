// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import SwiftyTextTable
import AppStoreConnect_Swift_SDK

extension UserInvitation {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Email"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Roles"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Provisioning Allowed"),
            TextTableColumn(header: "All Apps Visible")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            attributes?.email ?? "",
            attributes?.firstName ?? "",
            attributes?.lastName ?? "",
            attributes?.roles?.map { $0.rawValue }.joined(separator: ", ") ?? "",
            attributes?.expirationDate ?? "",
            attributes?.provisioningAllowed?.toYesNo() ?? "",
            attributes?.allAppsVisible?.toYesNo() ?? ""
        ]
    }
}
