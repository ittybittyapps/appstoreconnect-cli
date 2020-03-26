//
//  App.swift
//  AppStoreConnectCLI
//
//  Created by Huw Rowlands on 26/3/20.
//

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
    static func fromAPIApp(_ apiApp: AppStoreConnect_Swift_SDK.App) -> App {
        let attributes = apiApp.attributes
        return App(
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
            bundleId ?? "N/A",
            name ?? "N/A",
            primaryLocale ?? "N/A",
            sku ?? "N/A",
        ]
    }
}
