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
    init(_ attributes: AppStoreConnect_Swift_SDK.BundleId.Attributes) {
        self.init(
            identifier: attributes.identifier,
            name: attributes.name,
            platform: attributes.platform,
            seedId: attributes.seedId
        )
    }

    init(_ apiBundleId: AppStoreConnect_Swift_SDK.BundleId) {
        self.init(apiBundleId.attributes!)
    }

    init(_ response: AppStoreConnect_Swift_SDK.BundleIdResponse) {
        self.init(response.data)
    }
}

// MARK: - TextTable conveniences

extension BundleId: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "Identifier"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "Seed ID")
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
