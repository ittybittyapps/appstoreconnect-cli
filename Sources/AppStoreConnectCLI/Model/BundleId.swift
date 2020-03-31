// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct BundleId: ResultRenderable {
    var identifier: String?
    var name: String?
    var platform: BundleIdPlatform?
    var seedId: String?
}

// MARK: - API conveniences

extension BundleId {
    init(_ apiBundleId: AppStoreConnect_Swift_SDK.BundleId) {
        let attributes = apiBundleId.attributes
        self.init(
            identifier: attributes?.identifier,
            name: attributes?.name,
            platform: attributes?.platform,
            seedId: attributes?.seedId
        )
    }

    init(response: AppStoreConnect_Swift_SDK.BundleIdResponse) {
        let attributes = response.data.attributes
        self.init(
            identifier: attributes?.identifier,
            name: attributes?.name,
            platform: attributes?.platform,
            seedId: attributes?.seedId
        )
    }
}

// MARK: - TextTable conveniences

extension BundleId: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "identifier"),
            TextTableColumn(header: "name"),
            TextTableColumn(header: "platform"),
            TextTableColumn(header: "seedId")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            identifier ?? "",
            name ?? "",
            platform?.rawValue ?? "",
            seedId ?? ""
        ]
    }
}

extension HTTPClient {

    /// Find the opaque internal identifier for this bundle ID.
    ///
    /// This is an App Store Connect internal identifier; not the reverse-DNS bundleId identifier. Use this for reading, modifying and deleting bundleId resources.
    func findInternalIdentifier(for identifier: String) throws -> AnyPublisher<String, Error> {
        let request = APIEndpoint.listBundleIds(
            filter: [
                BundleIds.Filter.identifier([identifier])
            ]
        )

        return self.request(request)
            .map { $0.data.filter { $0.attributes?.identifier == identifier } }
            .compactMap { response -> String? in
                if response.count == 1 {
                    return response.first?.id
                }
                fatalError("Bundle ID identifier '\(identifier)' not unique or not found")
            }
            .eraseToAnyPublisher()
    }

}
