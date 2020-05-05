// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBetaGroupOperation: APIOperation {
    struct Options {
        let app: App
        let currentGroupName: String
        let newGroupName: String?
        let publicLinkEnabled: Bool?
        let publicLinkLimit: Int?
        let publicLinkLimitEnabled: Bool?
    }

    enum Error: LocalizedError {
        case betaGroupNotFound(groupName: String, bundleId: String)
        case betaGroupNotUniqueToApp(groupName: String, bundleId: String)

        var errorDescription: String? {
            switch self {
            case .betaGroupNotFound(let groupName, let bundleId):
                return "No beta group found with name: \(groupName) and bundle id: \(bundleId)"
            case .betaGroupNotUniqueToApp(let groupName, let bundleId):
                return "Multiple beta groups found with name: \(groupName) and app id: \(bundleId)"
            }
        }
    }

    typealias App = AppStoreConnect_Swift_SDK.App
    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<BetaGroup, Swift.Error> {
        let groupName = options.currentGroupName
        let appId = options.app.id
        let bundleId = options.app.attributes?.bundleId ?? ""

        let betaGroupsEndpoint = APIEndpoint.betaGroups(filter: [.app([appId]), .name([groupName])])
        let betaGroups = try requestor.request(betaGroupsEndpoint).await().data

        guard betaGroups.count == 1, let betaGroup = betaGroups.first else {
            switch betaGroups.count {
            case 0:
                throw Error.betaGroupNotFound(groupName: groupName, bundleId: bundleId)
            default:
                throw Error.betaGroupNotUniqueToApp(groupName: groupName, bundleId: bundleId)
            }
        }

        let endpoint: APIEndpoint<BetaGroupResponse> = .modify(
            betaGroupWithId: betaGroup.id,
            name: options.newGroupName,
            publicLinkEnabled: options.publicLinkEnabled,
            publicLinkLimit: options.publicLinkLimit,
            publicLinkLimitEnabled: options.publicLinkLimitEnabled
        )

        let response = requestor.request(endpoint)

        return response.map(\.data).eraseToAnyPublisher()
    }
}
