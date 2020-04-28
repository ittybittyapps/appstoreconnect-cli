// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaGroupsOperation: APIOperation {
    struct ListBetaGroupsDependencies {
        let apps: (APIEndpoint<AppsResponse>) -> Future<AppsResponse, Error>
        let betaGroups: (APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error>
    }

    private let endpoint: APIEndpoint<BetaGroupsResponse>

    init(options: ListBetaGroupsOptions) {
        endpoint = .betaGroups(include: [.app])
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[BetaGroup], Error> {
        let response = requestor.request(endpoint)

        let betaGroups = response.flatMap { response -> AnyPublisher<[BetaGroup], Error> in
            let seed: [String: AppStoreConnect_Swift_SDK.BetaGroup.Attributes] = [:]
            let betaGroupAttributes = response.data.reduce(into: seed) { result, data in
                (data.relationships?.app?.data?.id).map { result[$0] = data.attributes }
            }

            let appIds: [String] = Array(betaGroupAttributes.keys)
            let appsResponse = requestor.request(.apps(filters: [.id(appIds)]))

            let betaGroups = appsResponse.map { appsResponse in
                appsResponse.data.map { app -> BetaGroup in
                    let groupAttributes = betaGroupAttributes[app.id]
                    var betaGroup = BetaGroup(appId: app.id)
                    betaGroup.update(with: app.attributes)
                    betaGroup.update(with: groupAttributes)
                    return betaGroup
                }
            }

            return betaGroups.eraseToAnyPublisher()
        }

        return betaGroups.eraseToAnyPublisher()
    }
}
