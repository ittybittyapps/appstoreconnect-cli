// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import SwiftyTextTable

struct Profile: Codable {
    var name: String?
    var platform: BundleIdPlatform?
    var profileContent: String?
    var uuid: String?
    var createdDate: Date?
    var profileState: ProfileState?
    var profileType: ProfileType?
    var expirationDate: Date?
}

extension Profile {
    init(_ apiProfile: AppStoreConnect_Swift_SDK.Profile) {
        self.init(apiProfile.attributes!)
    }

    init(_ attributes: AppStoreConnect_Swift_SDK.Profile.Attributes) {
        self.init(
            name: attributes.name,
            platform: attributes.platform,
            profileContent: attributes.profileContent,
            uuid: attributes.uuid,
            createdDate: attributes.createdDate,
            profileState: attributes.profileState,
            profileType: attributes.profileType,
            expirationDate: attributes.expirationDate
        )
    }

    init(_ response: AppStoreConnect_Swift_SDK.ProfileResponse) {
        self.init(response.data)
    }
}

extension Profile: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "UUID"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "State"),
            TextTableColumn(header: "Type"),
            TextTableColumn(header: "Created Date"),
            TextTableColumn(header: "Expiration Date")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            uuid ?? "",
            name ?? "",
            platform?.rawValue ?? "",
            profileState?.rawValue ?? "",
            profileType?.rawValue ?? "",
            createdDate?.formattedDate ?? "",
            expirationDate?.formattedDate ?? ""
        ]
    }
}
