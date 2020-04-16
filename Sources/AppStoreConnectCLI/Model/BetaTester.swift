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
    let betaGroups: [BetaGroup]?
    let apps: [App]?

    init(email: String?,
         firstName: String?,
         lastName: String?,
         inviteType: BetaInviteType?,
         betaGroups: [BetaGroup]?,
         apps: [App]?) {
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

        let betaGroupsInTester = relationships?.betaGroups?.data?.compactMap { group -> [BetaGroup]? in
                includedBetaGroups?.filter { $0.id == group.id }
            }
            .flatMap { $0 }

        let appsInTester = relationships?.apps?.data?.compactMap { app -> [AppStoreConnect_Swift_SDK.App]? in
                includedApps?.filter { app.id == $0.id }
            }
            .flatMap { $0 }
            .map {
                App(bundleId: $0.attributes?.bundleId,
                    name: $0.attributes?.name,
                    primaryLocale: $0.attributes?.primaryLocale,
                    sku: $0.attributes?.sku)
            }

        self.init(email: attributes?.email,
                  firstName: attributes?.firstName,
                  lastName: attributes?.lastName,
                  inviteType: attributes?.inviteType,
                  betaGroups: betaGroupsInTester,
                  apps: appsInTester)
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
            email,
            firstName,
            lastName,
            inviteType,
            betaGroups?.compactMap { $0.attributes?.name }.joined(separator: ", "),
            apps?.compactMap { $0.bundleId }.joined(separator: ", ")
        ].map { $0 ?? "" }
    }
}
