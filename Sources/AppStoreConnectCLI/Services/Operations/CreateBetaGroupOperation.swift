// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {
    struct CreateBetaGroupDependencies {
        let createBetaGroup: (APIEndpoint<BetaGroupResponse>) -> Future<BetaGroupResponse, Error>
    }

    private let endpoint: APIEndpoint<BetaGroupResponse>

    init(options: CreateBetaGroupOptions) {
        endpoint = APIEndpoint.create(
            betaGroupForAppWithId: options.appBundleId,
            name: options.groupName
        )
    }

    func execute(with dependencies: CreateBetaGroupDependencies) -> AnyPublisher<BetaGroup, Error> {
        dependencies
            .createBetaGroup(endpoint)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
