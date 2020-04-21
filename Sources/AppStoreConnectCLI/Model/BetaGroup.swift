// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct BetaGroup: TableInfoProvider, ResultRenderable, Equatable {
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
        case couldntFindBetaGroup(groupNames: [String])
        case betaGroupNotUnique(groupNames: [String])

        var failureReason: String? {
            switch self {
                case .couldntFindBetaGroup(let groupNames):
                    return "Couldn't find beta group with input names \(groupNames)"
                case .betaGroupNotUnique(let groupNames):
                    return "The group name you input \(groupNames) are not unique"
            }
        }
    }

    /// Find the opaque internal identifier for this beta group; search by group name.
    ///
    /// This is an App Store Connect internal identifier
    func betaGroupIdentifier(matching name: String) -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.betaGroups(
            filter: [ListBetaGroups.Filter.name([name])]
        )

        return self.request(endpoint)
            .flatMap { response -> AnyPublisher<String, Error> in
                guard !response.data.isEmpty else {
                    let error = BetaGroupError.couldntFindBetaGroup(groupNames: [name])
                    return Fail(error: error).eraseToAnyPublisher()
                }

                guard response.data.count == 1, let id = response.data.first?.id else {
                    let error = BetaGroupError.betaGroupNotUnique(groupNames: [name])
                    return Fail(error: error).eraseToAnyPublisher()
                }

                return Result.Publisher(id).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func betaGroupIdentifiers(matching names: [String]) -> AnyPublisher<[String], Error> {
        let requests = names.map { self.betaGroupIdentifier(matching: $0) }

        return Publishers.MergeMany(requests)
            .reduce([]) { $0 + [$1] }
            .eraseToAnyPublisher()
    }
}
