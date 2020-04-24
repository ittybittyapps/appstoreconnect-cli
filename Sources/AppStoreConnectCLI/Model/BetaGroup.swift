// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct BetaGroup: TableInfoProvider, ResultRenderable {
    let appBundleId: String?
    let appName: String?
    let groupName: String?
    let isInternal: Bool?
    let publicLink: String?
    let publicLinkEnabled: Bool?
    let publicLinkLimit: Int?
    let publicLinkLimitEnabled: Bool?
    let creationDate: Date?

    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "App Bundle ID"),
            TextTableColumn(header: "App Name"),
            TextTableColumn(header: "Group Name"),
            TextTableColumn(header: "Is Internal"),
            TextTableColumn(header: "Public Link"),
            TextTableColumn(header: "Public Link Enabled"),
            TextTableColumn(header: "Public Link Limit"),
            TextTableColumn(header: "Public Link Limit Enabled"),
            TextTableColumn(header: "Creation Date"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        [
            appBundleId ?? "",
            appName ?? "",
            groupName ?? "",
            isInternal ?? "",
            publicLink ?? "",
            publicLinkEnabled ?? "",
            publicLinkLimit ?? "",
            publicLinkEnabled ?? "",
            creationDate ?? ""
        ]
    }
}

extension AppStoreConnectService {
    private enum BetaGroupError: LocalizedError {
        case couldntFindBetaGroup

        var failureReason: String? {
            switch self {
                case .couldntFindBetaGroup:
                    return "Couldn't find beta group with input name or group name not unique"
            }
        }
    }

    /// Find the opaque internal identifier for this beta group; search by group name.
    ///
    /// This is an App Store Connect internal identifier
    func betaGroupIdentifier(matching name: String) throws -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.betaGroups(
            filter: [ListBetaGroups.Filter.name([name])]
        )

        return self.request(endpoint)
            .tryMap { response throws -> String in
                guard response.data.count == 1, let id = response.data.first?.id else {
                    throw BetaGroupError.couldntFindBetaGroup
                }

                return id
            }
            .eraseToAnyPublisher()
    }
}
