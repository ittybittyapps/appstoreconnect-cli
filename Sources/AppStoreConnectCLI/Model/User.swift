// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftyTextTable

struct User: ResultRenderable {
    var username: String
    var firstName: String
    var lastName: String
    var roles: [UserRole]
    var provisioningAllowed: Bool
    var allAppsVisible: Bool
    var visibleApps: [String]?
}

// TODO: Extract these extensions somewhere that makes sense down the road

// MARK: - API conveniences

extension User {
    static func fromAPIUser(_ apiUser: AppStoreConnect_Swift_SDK.User) -> User? {
        guard let attributes = apiUser.attributes,
              let username = attributes.username else {
            // TODO: Error handling
            return nil
        }
        let visibleApps = apiUser.relationships?.visibleApps?.data?.map { $0.type }
        return User(username: username,
                    firstName: attributes.firstName ?? "",
                    lastName: attributes.lastName ?? "",
                    roles: attributes.roles ?? [],
                    provisioningAllowed: attributes.provisioningAllowed ?? false,
                    allAppsVisible: attributes.allAppsVisible ?? false,
                    visibleApps: visibleApps)
    }

    static func fromAPIResponse(_ response: UsersResponse) -> [User] {
        let users: [AppStoreConnect_Swift_SDK.User] = response.data

        return users.compactMap { (user: AppStoreConnect_Swift_SDK.User) -> User in
            let userVisibleAppIds = user.relationships?.visibleApps?.data?.compactMap { $0.id }
            let userVisibleApps = response.include?.filter {
                userVisibleAppIds?.contains($0.id) ?? false
            }

            guard let attributes = user.attributes else { fatalError("Failed to init user") }

            return User(attributes: attributes, visibleApps: userVisibleApps)
        }
    }

    init(attributes: AppStoreConnect_Swift_SDK.User.Attributes, visibleApps: [AppStoreConnect_Swift_SDK.App]? = nil) {
        self.username = attributes.username ?? ""
        self.firstName = attributes.firstName ?? ""
        self.lastName = attributes.lastName ?? ""
        self.roles = attributes.roles ?? []
        self.provisioningAllowed = attributes.provisioningAllowed ?? false
        self.allAppsVisible = attributes.allAppsVisible ?? false
        self.visibleApps = visibleApps?.compactMap{ $0.attributes?.bundleId }
    }
}

// MARK: - TextTable conveniences

extension User: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "Username"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Role"),
            TextTableColumn(header: "Provisioning Allowed"),
            TextTableColumn(header: "All Apps Visible"),
            TextTableColumn(header: "Visible Apps")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        [
            username,
            firstName,
            lastName,
            roles.map { $0.rawValue }.joined(separator: ", "),
            provisioningAllowed.toYesNo(),
            allAppsVisible.toYesNo(),
            visibleApps?.joined(separator: ", ") ?? ""
        ]
    }
}
