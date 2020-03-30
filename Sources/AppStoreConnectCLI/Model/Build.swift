// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import SwiftyTextTable
import AppStoreConnect_Swift_SDK

extension Build: ResultRenderable { }

extension Build: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Build Id"),
            TextTableColumn(header: "App Ids"),
            TextTableColumn(header: "Uploaded Date"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Version")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            id,
            relationships?.app?.data?.id ?? "",
            attributes?.uploadedDate ?? "",
            attributes?.expirationDate ?? "",
            attributes?.version ?? ""
        ]
    }
}
