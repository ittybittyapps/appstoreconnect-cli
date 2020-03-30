// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
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
