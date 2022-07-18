// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Bagbutik
import Foundation
import Combine
import struct Model.User
import struct Model.UserInvitation
import SwiftyTextTable

extension Model.UserInvitation {
    init(_ apiInvitation: Bagbutik.UserInvitation) {
        let attributes = apiInvitation.attributes!

        self.init(attributes)
    }

    init(_ attributes: Bagbutik.UserInvitation.Attributes) {
        self.init(
            username: attributes.email!,
            firstName: attributes.firstName!,
            lastName: attributes.lastName!,
            roles: (attributes.roles ?? []).map { .init($0) },
            provisioningAllowed: attributes.provisioningAllowed ?? false,
            allAppsVisible: attributes.allAppsVisible ?? false,
            expirationDate: attributes.expirationDate!
        )
    }
    
}

extension Model.UserInvitation: ResultRenderable { }

extension Model.UserInvitation: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Email"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Roles"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Provisioning Allowed"),
            TextTableColumn(header: "All Apps Visible"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            username,
            firstName ?? "",
            lastName ?? "",
            roles.map { $0.rawValue }.joined(separator: ", "),
            expirationDate,
            provisioningAllowed.toYesNo(),
            allAppsVisible.toYesNo(),
        ]
    }
}

extension APIEndpoint where T == AppStoreConnect_Swift_SDK.UserInvitationResponse {
    static func invite(user: Model.User) -> Self {
        invite(
            userWithEmail: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            roles: user.roles.compactMap(UserRole.init(rawValue:)),
            allAppsVisible: user.allAppsVisible,
            provisioningAllowed: user.provisioningAllowed,
            appsVisibleIds: user.allAppsVisible ? [] : user.visibleApps
        )
    }
}
