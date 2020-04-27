// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import SwiftyTextTable

struct BetaGroup: TableInfoProvider, ResultRenderable, Equatable {
    let appId: String
    var appBundleId: String?
    var appName: String?
    var groupName: String?
    var isInternal: Bool?
    var publicLink: String?
    var publicLinkEnabled: Bool?
    var publicLinkLimit: Int?
    var publicLinkLimitEnabled: Bool?
    var creationDate: Date?

    init(appId: String) {
        self.appId = appId
    }

    mutating func update(with attributes: AppStoreConnect_Swift_SDK.App.Attributes?) {
        appBundleId = attributes?.bundleId
        appName = attributes?.name
    }

    mutating func update(with attributes: AppStoreConnect_Swift_SDK.BetaGroup.Attributes?) {
        groupName = attributes?.name
        isInternal = attributes?.isInternalGroup
        publicLink = attributes?.publicLink
        publicLinkEnabled = attributes?.publicLinkEnabled
        publicLinkLimit = attributes?.publicLinkLimit
        publicLinkLimitEnabled = attributes?.publicLinkLimitEnabled
        creationDate = attributes?.createdDate
    }

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
            appId,
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
