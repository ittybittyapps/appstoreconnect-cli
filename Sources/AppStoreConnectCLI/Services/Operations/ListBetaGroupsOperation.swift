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

    func execute(with dependencies: ListBetaGroupsDependencies) -> AnyPublisher<[BetaGroup], Error> {
        let response = dependencies.betaGroups(endpoint)

        let betaGroups = response.map { response in
            response.data.map {
                BetaGroup(
                    appBundleId: nil,
                    appName: nil,
                    groupName: $0.attributes?.name,
                    isInternal: $0.attributes?.isInternalGroup,
                    publicLink: $0.attributes?.publicLink,
                    publicLinkEnabled: $0.attributes?.publicLinkEnabled,
                    publicLinkLimit: $0.attributes?.publicLinkLimit,
                    publicLinkLimitEnabled: $0.attributes?.publicLinkLimitEnabled,
                    creationDate: $0.attributes?.createdDate
                )
            }
        }

        return betaGroups.eraseToAnyPublisher()
    }
}
