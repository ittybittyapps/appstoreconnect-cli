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

extension AppStoreConnectService {

    private enum AppError: LocalizedError {
        case couldntFindApp(bundleId: [String])
        case bundleIdNotUnique(bundleId: String)

        var failureReason: String? {
            switch self {
                case .couldntFindApp(let bundleIds):
                    return "No apps were found matching \(bundleIds)"
                case .bundleIdNotUnique(let bundleId):
                    return "BundleId \(bundleId) is not unique"
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

    /// Find a opaque internal identifier for an application that related to this bundle ID.
    func appResourceId(matching bundleId: String) -> AnyPublisher<String, Error> {
        let getAppResourceIdRequest = APIEndpoint.apps(
            filters: [ListApps.Filter.bundleId([bundleId])]
        )

        return self.request(getAppResourceIdRequest)
            .tryMap { (response: AppsResponse) throws -> String in
                guard !response.data.isEmpty else {
                    throw AppError.couldntFindApp(bundleId: [bundleId])
                }

                guard response.data.count == 1, let app = response.data.first else {
                    throw AppError.bundleIdNotUnique(bundleId: bundleId)
                }

                return app.id
            }
            .eraseToAnyPublisher()
    }
}
