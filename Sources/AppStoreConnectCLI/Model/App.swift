// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.App
import SwiftyTextTable

extension App: ResultRenderable {}

// MARK: - API conveniences

extension App {
    init(_ apiApp: AppStoreConnect_Swift_SDK.App) {
        let attributes = apiApp.attributes
        self.init(
            id: apiApp.id,
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
            TextTableColumn(header: "App ID"),
            TextTableColumn(header: "App Bundle ID"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Primary Locale"),
            TextTableColumn(header: "SKU"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            id,
            bundleId ?? "",
            name ?? "",
            primaryLocale ?? "",
            sku ?? "",
        ]
    }
}

extension AppStoreConnectService {

    private enum AppError: LocalizedError {
        case couldntFindApp(bundleId: [String])

        var errorDescription: String? {
            switch self {
            case .couldntFindApp(let bundleIds):
                return "No apps were found matching \(bundleIds)."
            }
        }
    }

    /// Find the opaque internal identifier for an application that related to this bundle ID.
    func getAppResourceIdsFrom(bundleIds: [String]) -> AnyPublisher<[String], Error> {
        let getAppResourceIdRequest = APIEndpoint.apps(
            filters: [ListApps.Filter.bundleId(bundleIds)]
        )

        return self.request(getAppResourceIdRequest)
            .tryMap { (response: AppsResponse) throws -> [AppStoreConnect_Swift_SDK.App] in
                guard !response.data.isEmpty else {
                    throw AppError.couldntFindApp(bundleId: bundleIds)
                }

                return response.data
            }
            .compactMap { $0.map { $0.id } }
            .eraseToAnyPublisher()
    }
}
