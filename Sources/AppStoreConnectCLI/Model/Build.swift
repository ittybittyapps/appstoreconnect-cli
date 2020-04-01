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
            TextTableColumn(header: "Min OS Version"),
            TextTableColumn(header: "Version")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        let dateFormatter = DateFormatter()
        return [
           id,
           dateFormatter.formatDateToString(attributes?.uploadedDate),
           dateFormatter.formatDateToString(attributes?.expirationDate),
           attributes?.minOsVersion ?? "",
           attributes?.version ?? ""
        ]
    }
}
