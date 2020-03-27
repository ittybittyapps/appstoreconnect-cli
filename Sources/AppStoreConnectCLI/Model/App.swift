// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftyTextTable

struct App: Codable {
    var bundleId: String?
    var name: String?
    var primaryLocale: String?
    var sku: String?
}

// MARK: - API conveniences

extension App {
    init(_ apiApp: AppStoreConnect_Swift_SDK.App) {
        let attributes = apiApp.attributes
        self.init(
            bundleId: attributes?.bundleId,
            name: attributes?.name,
            primaryLocale: attributes?.primaryLocale,
            sku: attributes?.sku
        )
    }
}

// MARK: - TextTable conveniences

extension App {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "bundleId"),
            TextTableColumn(header: "name"),
            TextTableColumn(header: "primaryLocale"),
            TextTableColumn(header: "sku"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            bundleId ?? "",
            name ?? "",
            primaryLocale ?? "",
            sku ?? "",
        ]
    }
}
