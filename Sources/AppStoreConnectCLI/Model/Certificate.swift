// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import SwiftyTextTable

struct Certificate: ResultRenderable {
    let name: String?
    let type: CertificateType?
    let content: String?
    let platform: BundleIdPlatform?
    let expirationDate: Date?
}

extension Certificate {
    init(_ certificate: AppStoreConnect_Swift_SDK.Certificate) {
        self.init(certificate.attributes)
    }

    init(_ attributes: AppStoreConnect_Swift_SDK.Certificate.Attributes) {
        self.init(
            name: attributes.name,
            type: attributes.certificateType,
            content: attributes.certificateContent,
            platform: attributes.platform,
            expirationDate: attributes.expirationDate
        )
    }
}

extension Certificate: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Type"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "Expiration Date"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        [
            self.name ?? "",
            self.type?.rawValue ?? "",
            self.platform?.rawValue ?? "",
            self.expirationDate ?? ""
        ]
    }
}
