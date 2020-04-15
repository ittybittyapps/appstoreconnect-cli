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

        let apps = includes?.compactMap { relationship -> App? in
            if case let .app(app) = relationship {
                return App(bundleId: app.attributes?.bundleId,
                           name: app.attributes?.name,
                           primaryLocale: app.attributes?.primaryLocale,
                           sku: app.attributes?.sku)
            }

            return nil
        }

        let betaGroups = includes?.compactMap { relationship -> BetaGroup? in
            if case let .betaGroup(betaGroup) = relationship {
                return betaGroup
            }

            return nil
        }

        self.init(email: attributes?.email,
                  firstName: attributes?.firstName,
                  lastName: attributes?.lastName,
                  inviteType: attributes?.inviteType,
                  betaGroups: betaGroups,
                  apps: apps)
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
            betaGroups?.compactMap { $0.attributes?.name }.joined(separator: ", ") ?? "",
            apps?.compactMap { $0.bundleId }.joined(separator: ", ") ?? ""
        ]
    }
}

extension HTTPClient {

    private enum BetaTesterError: Error, CustomStringConvertible {
        case couldntFindBetaTester

        var description: String {
            switch self {
                case .couldntFindBetaTester:
                    return "Couldn't find beta tester with input email or tester email not unique"
            }
        }
    }

    /// Find the opaque internal identifier for this tester; search by email adddress.
    ///
    /// This is an App Store Connect internal identifier
    func betaTesterResourceId(matching email: String) throws -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.betaTesters(
            filter: [ListBetaTesters.Filter.email([email])]
        )

        return self.request(endpoint)
            .tryMap { response throws -> String in
                guard response.data.count == 1, let id = response.data.first?.id else {
                    throw BetaTesterError.couldntFindBetaTester
                }

                return id
            }
            .eraseToAnyPublisher()
    }

}
