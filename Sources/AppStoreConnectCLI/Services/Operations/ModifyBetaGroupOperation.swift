// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBetaGroupOperation: APIOperation {
    struct Options {
        let appId: String
        let currentGroupName: String
        let newGroupName: String?
        let publicLinkEnabled: Bool?
        let publicLinkLimit: Int?
        let publicLinkLimitEnabled: Bool?
    }

    enum Error: LocalizedError {
        case betaGroupNotFound(groupName: String, appId: String)
        case betaGroupNotUniqueToApp(groupName: String, appId: String)

        var errorDescription: String? {
            switch self {
            case .betaGroupNotFound(let groupName, let appId):
                return "No beta group found with name: \(groupName) and app id: \(appId)"
            case .betaGroupNotUniqueToApp(let groupName, let appId):
                return "Multiple beta groups found with name: \(groupName) and app id: \(appId)"
            }
        }
    }

    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<BetaGroup, Swift.Error> {
        let groupName = options.currentGroupName
        let appId = options.appId

        let betaGroupsEndpoint = APIEndpoint.betaGroups(filter: [.app([appId]), .name([groupName])])
        let betaGroups = try requestor.request(betaGroupsEndpoint).await().data

        guard betaGroups.count == 1, let betaGroup = betaGroups.first else {
            let groupName = options.currentGroupName
            let appId = options.appId

            switch betaGroups.count {
            case 0:
                throw Error.betaGroupNotFound(groupName: groupName, appId: appId)
            default:
                throw Error.betaGroupNotUniqueToApp(groupName: groupName, appId: appId)
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
