// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import Model
import SwiftyTextTable

extension Model.Profile {
    init(_ apiProfile: AppStoreConnect_Swift_SDK.Profile) {
        self.init(apiProfile.attributes!)
    }

    init(_ attributes: AppStoreConnect_Swift_SDK.Profile.Attributes) {
        self.init(
            name: attributes.name,
            platform: attributes.platform?.rawValue,
            profileContent: attributes.profileContent,
            uuid: attributes.uuid,
            createdDate: attributes.createdDate,
            profileState: attributes.profileState?.rawValue,
            profileType: attributes.profileType?.rawValue,
            expirationDate: attributes.expirationDate
        )
    }

    init(_ response: AppStoreConnect_Swift_SDK.ProfileResponse) {
        self.init(response.data)
    }
}

extension Model.Profile: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "UUID"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "State"),
            TextTableColumn(header: "Type"),
            TextTableColumn(header: "Created Date"),
            TextTableColumn(header: "Expiration Date"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            uuid ?? "",
            name ?? "",
            platform ?? "",
            profileState ?? "",
            profileType ?? "",
            createdDate?.formattedDate ?? "",
            expirationDate?.formattedDate ?? "",
        ]
    }
}
