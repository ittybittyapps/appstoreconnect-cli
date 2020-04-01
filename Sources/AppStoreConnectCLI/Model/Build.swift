// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import SwiftyTextTable

extension Build: ResultRenderable { }

extension Build: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "ID"),
            TextTableColumn(header: "Uploaded Date"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Expired"),
            TextTableColumn(header: "Min OS Version"),
            TextTableColumn(header: "Version"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            id,
            attributes?.uploadedDate?.formattedDate ?? "",
            attributes?.expirationDate?.formattedDate ?? "",
            attributes?.expired?.toYesNo() ?? "",
            attributes?.minOsVersion ?? "",
            attributes?.version ?? ""
        ]
    }
}
