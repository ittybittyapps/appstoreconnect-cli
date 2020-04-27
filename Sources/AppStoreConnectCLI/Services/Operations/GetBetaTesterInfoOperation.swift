// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaTesterInfoOperation: APIOperation {

    struct GetBetaTesterInfoDependencies {
        let betaTesterResponse: (APIEndpoint<BetaTesterResponse>) -> Future<BetaTesterResponse, Error>
    }

    private let endpoint: APIEndpoint<BetaTesterResponse>

    init(options: GetBetaTesterInfoOptions) {
        endpoint = APIEndpoint.betaTester(
            withId: options.id,
            include: [GetBetaTester.Include.betaGroups,
                      GetBetaTester.Include.apps])
    }

    func execute(with dependencies: GetBetaTesterInfoDependencies) -> AnyPublisher<BetaTester, Error> {
        dependencies.betaTesterResponse(endpoint)
            .map { BetaTester($0.data, $0.included) }
            .eraseToAnyPublisher()
    }

}
