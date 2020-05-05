// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaGroupOperation: APIOperation {
    struct Options {
        let app: App
        let betaGroupName: String
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

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaGroup, Swift.Error> {
        let betaGroupName = options.betaGroupName
        let bundleId = options.app.attributes?.bundleId ?? ""

        let endpoint = APIEndpoint.betaGroups(
            filter: [.app([options.app.id]), .name([betaGroupName])]
        )

        let betaGroup = requestor.request(endpoint).tryMap { response -> BetaGroup in
            switch response.data.first {
            case .some(let betaGroup) where response.data.count == 1:
                return betaGroup
            case .some:
                throw Error.betaGroupNotUniqueToApp(groupName: betaGroupName, bundleId: bundleId)
            case .none:
                throw Error.betaGroupNotFound(groupName: betaGroupName, bundleId: bundleId)
            }
        }

        return betaGroup.eraseToAnyPublisher()
    }
}
