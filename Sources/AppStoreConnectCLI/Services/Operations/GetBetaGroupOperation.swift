// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaGroupOperation: APIOperation {

    struct Options {
        let appId: String?
        let bundleId: String?
        let betaGroupName: String
    }

    enum Error: LocalizedError {
        case betaGroupNotFound(groupName: String, bundleId: String, appId: String)
        case betaGroupNotUniqueToApp(groupName: String, bundleId: String, appId: String)

        var errorDescription: String? {
            switch self {
            case .betaGroupNotFound(let groupName, let bundleId, let appId):
                return "No beta group found with name: \(groupName) and bundle id: \(bundleId) and app id: \(appId)"
            case .betaGroupNotUniqueToApp(let groupName, let bundleId, let appId):
                return "Multiple beta groups found with name: \(groupName) and bundle id: \(bundleId) and app id: \(appId)"
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
        let bundleId = options.bundleId ?? ""
        let appId = options.appId ?? ""

        var filters: [ListBetaGroups.Filter] = [.name([betaGroupName])]
        filters += appId.isEmpty ? [] : [.app([appId])]

        let endpoint = APIEndpoint.betaGroups(filter: filters)

        let betaGroup = requestor.request(endpoint).tryMap { response -> BetaGroup in
            let betaGroups = response.data.filter { $0.attributes?.name == betaGroupName }

            switch (betaGroups.first, betaGroups.count) {
            case (.some(let betaGroup), 1):
                return betaGroup
            case (.some, _):
                throw Error.betaGroupNotUniqueToApp(groupName: betaGroupName, bundleId: bundleId, appId: appId)
            case (.none, _):
                throw Error.betaGroupNotFound(groupName: betaGroupName, bundleId: bundleId, appId: appId)
            }
        }

        return betaGroup.eraseToAnyPublisher()
    }

}
