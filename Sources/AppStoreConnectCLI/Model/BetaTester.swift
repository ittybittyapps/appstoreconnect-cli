// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct BetaTester: ResultRenderable {
    let email: String?
    let firstName: String?
    let lastName: String?
    let inviteType: String?
    let betaGroups: [String]?
    let apps: [String]?

    init(email: String?,
         firstName: String?,
         lastName: String?,
         inviteType: BetaInviteType?,
         betaGroups: [String]?,
         apps: [String]?) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.inviteType = inviteType?.rawValue
        self.betaGroups = betaGroups
        self.apps = apps
    }

    init(_ betaTester: AppStoreConnect_Swift_SDK.BetaTester, _ includes: [AppStoreConnect_Swift_SDK.BetaTesterRelationship]?) {
        let attributes = betaTester.attributes
        let relationships = betaTester.relationships

        let includedApps = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.App? in
            if case let .app(app) = relationship {
                return app
            }
            return nil
        }

        let includedBetaGroups = includes?.compactMap { relationship -> BetaGroup? in
            if case let .betaGroup(betaGroup) = relationship {
                return betaGroup
            }
            return nil
        }

        // Find tester related beta groups and apps in included data
        let betaGroupsNames = relationships?.betaGroups?.data?.compactMap { group -> [BetaGroup]? in
                includedBetaGroups?.filter { $0.id == group.id }
            }
            .flatMap { $0.compactMap { $0.attributes?.name } }

        let appsBundleIds = relationships?.apps?.data?.compactMap { app -> [AppStoreConnect_Swift_SDK.App]? in
                includedApps?.filter { app.id == $0.id }
            }
            .flatMap { $0.compactMap { $0.attributes?.bundleId } }

        self.init(email: attributes?.email,
                  firstName: attributes?.firstName,
                  lastName: attributes?.lastName,
                  inviteType: attributes?.inviteType,
                  betaGroups: betaGroupsNames,
                  apps: appsBundleIds)
    }
}

extension BetaTester: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Email"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Invite Type"),
            TextTableColumn(header: "Beta Groups"),
            TextTableColumn(header: "Apps")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            email ?? "",
            firstName ?? "",
            lastName ?? "",
            inviteType ?? "",
            betaGroups?.joined(separator: ", ") ?? [],
            apps?.joined(separator: ", ") ?? []
        ]
    }
}
