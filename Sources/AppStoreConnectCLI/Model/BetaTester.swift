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
    func betaTesterIdentifier(matching email: String) throws -> AnyPublisher<String, Error> {
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

    private enum TransformStrategy {
        case hasApps(appIds: [String])
        case hasGroups(groupIds: [String])
        case hasBoth(appIds: [String], groupIds: [String])
        case none

        init(groupIds: [String]?, appIds: [String]?) {
            switch (groupIds, appIds) {
                case let(.some(groupIds), _) where !groupIds.isEmpty:
                    self = .hasGroups(groupIds:groupIds)
                case let(_, .some(appIds)) where !appIds.isEmpty:
                    self = .hasApps(appIds: appIds)
                case let(.some(groupIds), .some(appIds)) where !groupIds.isEmpty && !appIds.isEmpty:
                    self = .hasBoth(appIds: appIds, groupIds: groupIds)
                case (_, _):
                    self = .none
            }
        }
    }

    func fromAPIBetaTesters(betaTesters: [AppStoreConnect_Swift_SDK.BetaTester]) -> AnyPublisher<[BetaTester], Error> {
        let betaTesters = betaTesters.map { (tester: AppStoreConnect_Swift_SDK.BetaTester) -> AnyPublisher<BetaTester, Error> in
            let groupIds = tester.relationships?.betaGroups?.data?.compactMap { $0.id }
            let appIds = tester.relationships?.apps?.data?.compactMap { $0.id }

            switch TransformStrategy(groupIds: groupIds, appIds: appIds) {
                case .hasApps(let appIds):
                    let endpoint = APIEndpoint.apps(
                        filters: [ListApps.Filter.id(appIds)]
                    )

                    return self.request(endpoint)
                        .map(\.data)
                        .map { (apps: [AppStoreConnect_Swift_SDK.App]) in
                            let apps = apps.map { App(bundleId: $0.attributes?.bundleId,
                                                      name: $0.attributes?.name,
                                                      primaryLocale: $0.attributes?.primaryLocale,
                                                      sku: $0.attributes?.sku) }

                            return BetaTester(
                                email: tester.attributes?.email,
                                firstName: tester.attributes?.firstName,
                                lastName: tester.attributes?.lastName,
                                inviteType: tester.attributes?.inviteType,
                                betaGroups: nil,
                                apps: apps
                            )
                        }
                        .eraseToAnyPublisher()

                case .hasGroups(let groupIds):
                    let endpoint = APIEndpoint.betaGroups(
                        filter: [ListBetaGroups.Filter.id(groupIds)]
                    )

                    return self.request(endpoint)
                        .map(\.data)
                        .map { (groups: [BetaGroup]) in
                            return BetaTester(
                                email: tester.attributes?.email,
                                firstName: tester.attributes?.firstName,
                                lastName: tester.attributes?.lastName,
                                inviteType: tester.attributes?.inviteType,
                                betaGroups: groups,
                                apps: nil)
                        }
                        .eraseToAnyPublisher()

                case .hasBoth(let appIds, let groupIds):
                    let betaGroupEndpoint = APIEndpoint.betaGroups(
                        filter: [ListBetaGroups.Filter.id(groupIds)]
                    )

                    let appsEndpoint = APIEndpoint.apps(
                        filters: [ListApps.Filter.id(appIds)]
                    )

                    return self.request(betaGroupEndpoint)
                        .combineLatest(self.request(appsEndpoint))
                        .map { ($0.0.data, $0.1.data) }
                        .map {
                            return BetaTester(
                                email: tester.attributes?.email,
                                firstName: tester.attributes?.firstName,
                                lastName: tester.attributes?.lastName,
                                inviteType: tester.attributes?.inviteType,
                                betaGroups: $0,
                                apps: $1.map { App(bundleId: $0.attributes?.bundleId,
                                                   name: $0.attributes?.name,
                                                   primaryLocale: $0.attributes?.primaryLocale,
                                                   sku: $0.attributes?.sku) }
                            )
                        }
                        .eraseToAnyPublisher()

                case .none:
                    let tester = BetaTester(
                        email: tester.attributes?.email,
                        firstName: tester.attributes?.firstName,
                        lastName: tester.attributes?.lastName,
                        inviteType: tester.attributes?.inviteType,
                        betaGroups: nil,
                        apps: nil
                    )

                    return Empty<BetaTester, Error>()
                        .append(tester)
                        .eraseToAnyPublisher()
            }
        }

        return Publishers.MergeMany(betaTesters).reduce([], { $0 + [$1] }).eraseToAnyPublisher()
    }
}
