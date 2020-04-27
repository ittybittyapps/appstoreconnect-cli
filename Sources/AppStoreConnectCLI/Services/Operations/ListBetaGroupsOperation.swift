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
        endpoint = .betaGroups()
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[BetaGroup], Error> {
        let response = requestor.request(endpoint)

        let betaGroups = response.map { response in
            response.data.map { betaGroupData -> BetaGroup in
                var betaGroup = BetaGroup(appId: "")

                if let attributes = betaGroupData.attributes {
                    betaGroup.update(with: attributes)
                }

                return betaGroup
            }
        }

        return betaGroups.eraseToAnyPublisher()
    }
}
