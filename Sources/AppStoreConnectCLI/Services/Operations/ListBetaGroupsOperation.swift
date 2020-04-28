// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaGroupsOperation: APIOperation {
    struct ListBetaGroupsDependencies {
        let betaGroups: (APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error>
    }

    private let endpoint: APIEndpoint<BetaGroupsResponse>

    init(options: ListBetaGroupsOptions) {
        let filters = options.appIds.isEmpty ? [] : [ListBetaGroups.Filter.app(options.appIds)]
        endpoint = .betaGroups(filter: filters, include: [.app])
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[BetaGroup], Error> {
        let response = requestor.request(endpoint)

        let betaGroups = response.map { response -> [BetaGroup] in
            var betaGroups: [String: BetaGroup] = [:]

            response.included?.forEach { relationship in
                if case .app(let app) = relationship {
                    var betaGroup = BetaGroup(appId: app.id)
                    betaGroup.update(with: app.attributes)
                    betaGroups[app.id] = betaGroup
                }
            }

            response.data.forEach { groupData in
                if let appId = groupData.relationships?.app?.data?.id {
                    betaGroups[appId]?.update(with: groupData.attributes)
                }
            }

            return Array(betaGroups.values)
        }

        return betaGroups.eraseToAnyPublisher()
    }
}
