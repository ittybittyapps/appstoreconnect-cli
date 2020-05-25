// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import Model
import SwiftyTextTable

extension Model.Certificate {
    init(_ certificate: AppStoreConnect_Swift_SDK.Certificate) {
        self.init(certificate.attributes)
    }

    init(_ attributes: AppStoreConnect_Swift_SDK.Certificate.Attributes) {
        self.init(
            name: attributes.name,
            type: attributes.certificateType?.rawValue,
            content: attributes.certificateContent,
            platform: attributes.platform?.rawValue,
            expirationDate: attributes.expirationDate,
            serialNumber: attributes.serialNumber
        )
    }
}

extension Model.Certificate: ResultRenderable, TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "SerialNumber"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Type"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "Expiration Date"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        [
            self.serialNumber ?? "",
            self.name ?? "",
            self.type ?? "",
            self.platform ?? "",
            self.expirationDate ?? ""
        ]
    }
}
