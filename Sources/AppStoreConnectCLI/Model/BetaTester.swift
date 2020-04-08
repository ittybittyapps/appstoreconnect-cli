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
    
}
