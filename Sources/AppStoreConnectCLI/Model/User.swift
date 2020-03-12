// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftyTextTable

struct User: Codable {
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
}

// MARK: - TextTable conveniences

extension User {
    static func getTableColumns(includeVisibleApps: Bool) -> [TextTableColumn] {
        var columns = [
            TextTableColumn(header: "Username"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Role"),
            TextTableColumn(header: "Provisioning Allowed"),
            TextTableColumn(header: "All Apps Visible")
        ]

        if includeVisibleApps {
            columns.append(TextTableColumn(header: "Visible Apps"))
        }
        return columns
    }
    var tableRow: [CustomStringConvertible] {
        return [
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
