// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct App: ResultRenderable {
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

extension App: TableInfoProvider {
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

extension HTTPClient {

    /// Find the opaque internal identifier for an application that related to this bundle ID.
    func getAppResourceIdsFrom(bundleIds: [String]) -> AnyPublisher<[String], Error> {
        let getAppResourceIdRequest = APIEndpoint.apps(
            filters: [ListApps.Filter.bundleId(bundleIds)]
        )

        return self.request(getAppResourceIdRequest)
            .map { $0.data }
            .compactMap { $0.map { $0.id } }
            .eraseToAnyPublisher()
    }
}
