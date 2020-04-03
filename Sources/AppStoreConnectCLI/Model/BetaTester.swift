// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftyTextTable

extension BetaTester: ResultRenderable { }

extension BetaTester: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Email"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Invite Type")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            attributes?.email ?? "",
            attributes?.firstName ?? "",
            attributes?.lastName ?? "",
            betaInviteType
        ]
    }

    var betaInviteType: String {
        return attributes?.inviteType?.rawValue ?? ""
    }

    var appsId: [String] {
        return relationships?.apps?.data?.compactMap { $0.id } ?? []
    }

    var betaGroupsIds: [String] {
        return relationships?.betaGroups?.data?.compactMap { $0.id } ?? []
    }

    var buildsIds: [String] {
        return relationships?.builds?.data?.compactMap { $0.id } ?? []
    }
}
