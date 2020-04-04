// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
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

extension HTTPClient {

    /// Find the opaque internal identifier for this user; search by email adddress.
    ///
    /// This is an App Store Connect internal identifier
    func userIdentifier(matching email: String) -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.users(
            filter: [
                ListUsers.Filter.username([email])
            ]
        )

        return self.request(endpoint)
            .map { $0.data.filter { $0.attributes?.username == email } }
            .compactMap { response -> String? in
                if response.count == 1 {
                    return response.first?.id
                }
                fatalError("User with email address '\(email)' not unique or not found")
            }
            .eraseToAnyPublisher()
    }

}
