// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct BetaGroup: TableInfoProvider, ResultRenderable, Equatable {
    let app: App
    let groupName: String?
    let isInternal: Bool?
    let publicLink: String?
    let publicLinkEnabled: Bool?
    let publicLinkLimit: Int?
    let publicLinkLimitEnabled: Bool?
    let creationDate: String?

    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "App ID"),
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
            app.id,
            app.bundleId ?? "",
            app.name ?? "",
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

extension BetaGroup {
    init(
        extendedBetaGroup: ExtendedBetaGroup
    ) {
        app = App(extendedBetaGroup.app)
        groupName = extendedBetaGroup.betaGroup.attributes?.name
        isInternal = extendedBetaGroup.betaGroup.attributes?.isInternalGroup
        publicLink = extendedBetaGroup.betaGroup.attributes?.publicLink
        publicLinkEnabled = extendedBetaGroup.betaGroup.attributes?.publicLinkEnabled
        publicLinkLimit = extendedBetaGroup.betaGroup.attributes?.publicLinkLimit
        publicLinkLimitEnabled = extendedBetaGroup.betaGroup.attributes?.publicLinkLimitEnabled
        creationDate = extendedBetaGroup.betaGroup.attributes?.createdDate?.formattedDate
    }
}

extension AppStoreConnectService {
    private enum BetaGroupError: LocalizedError {
        case betaGroupNotFound(groupNames: [String])
        case betaGroupNotUnique(groupNames: [String])

        var errorDescription: String? {
            switch self {
            case .betaGroupNotFound(let groupNames):
                return "Couldn't find beta group with input names \(groupNames)."
            case .betaGroupNotUnique(let groupNames):
                return "The group name you input \(groupNames) are not unique."
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
                    let error = BetaGroupError.betaGroupNotFound(groupNames: [name])
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
}
