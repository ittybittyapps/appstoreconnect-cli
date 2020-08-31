// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import Model
import SwiftyTextTable

extension Model.BetaTester {

    init(_ output: GetBetaTesterOperation.Output) {
        let betaTester = output.betaTester
        let appRelationships = (betaTester.relationships?.apps?.data) ?? []
        let betaGroupRelationships = (betaTester.relationships?.betaGroups?.data) ?? []

        let apps = appRelationships.compactMap { relationship -> AppStoreConnect_Swift_SDK.App? in
            output.apps?.first { app in relationship.id == app.id }
        }

        let betaGroups = betaGroupRelationships.compactMap { relationship -> AppStoreConnect_Swift_SDK.BetaGroup? in
            output.betaGroups?.first { betaGroup in relationship.id == betaGroup.id }
        }

        self.init(
            email: betaTester.attributes?.email,
            firstName: betaTester.attributes?.firstName,
            lastName: betaTester.attributes?.lastName,
            inviteType: betaTester.attributes?.inviteType?.rawValue,
            betaGroups: betaGroups.map { Model.BetaGroup(nil, $0) },
            apps: apps.map(Model.App.init)
        )
    }

}

extension Model.BetaTester: ResultRenderable, TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Email"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Invite Type"),
            TextTableColumn(header: "Beta Groups"),
            TextTableColumn(header: "Apps"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            email ?? "",
            firstName ?? "",
            lastName ?? "",
            inviteType ?? "",
            betaGroups.compactMap(\.groupName).joined(separator: ", "),
            apps.compactMap(\.bundleId).joined(separator: ", "),
        ]
    }
}
