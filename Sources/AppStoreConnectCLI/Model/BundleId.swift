// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

enum BundleIdCapability: String, Decodable {
    case icloud
    case inAppPurchase
    case gameCenter
    case pushNotifications
    case wallet
    case interAppAudio
    case maps
    case associatedDomains
    case personalVpn
    case appGroups
    case healthkit
    case homekit
    case wirelessAccessoryConfiguration
    case applePay
    case dataProtection
    case sirikit
    case networkExtensions
    case multipath
    case hotSpot
    case nfcTagReading
    case classkit
    case autofillCredentialProvider
    case accessWifiInformation
}

struct BundleId: ResultRenderable {
    var id: String?
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
            id: apiBundleId.id,
            identifier: attributes?.identifier,
            name: attributes?.name,
            platform: attributes?.platform,
            seedId: attributes?.seedId
        )
    }

    init(response: AppStoreConnect_Swift_SDK.BundleIdResponse) {
        let attributes = response.data.attributes
        self.init(
            id: response.data.id,
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

    /// Find the opaque identifier for this bundle ID.
    ///
    /// This is an App Store Connect internal identifier; not the bundle-id. Use this for reading, modifying and deleting bundle-id resources.
    func findInternalIdentifier(for bundleId: String) throws -> AnyPublisher<String, Error> {
        let request = APIEndpoint.listBundleIds(
            filter: [
                BundleIds.Filter.identifier([bundleId])
            ]
        )

        return self.request(request)
            .map { $0.data.map(BundleId.init) }
            .map { $0.filter { $0.identifier == bundleId } }
            .compactMap { response -> String? in
                if response.count == 1 {
                    return response.first?.id
                }
                fatalError("Bundle ID '\(bundleId)' not unique or not found")
            }
            .eraseToAnyPublisher()
    }

}
