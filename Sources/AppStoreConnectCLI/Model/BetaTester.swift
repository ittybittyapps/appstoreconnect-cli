// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
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

extension HTTPClient {

    /// Find the opaque internal identifier for this tester; search by email adddress.
    ///
    /// This is an App Store Connect internal identifier
    func betaTesterIdentifier(matching email: String) -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.betaTesters(
            filter: [ListBetaTesters.Filter.email([email])]
        )

        return self.request(endpoint)
            .map { $0.data.map { $0.id } }
            .compactMap { response -> String? in
                if response.count == 1 {
                    return response.first
                }

                fatalError("Tester with email \(email) not unique or not found")
            }
            .eraseToAnyPublisher()
    }
    
}
