// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaTesterInfoOperation: APIOperation {

    private let endpoint: APIEndpoint<BetaTesterResponse>

    init(options: GetBetaTesterInfoOptions) {
        endpoint = APIEndpoint.betaTester(
            withId: options.id,
            include: [.betaGroups, .apps])
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaTester, Error> {
        requestor.request(endpoint)
            .map { BetaTester($0.data, $0.included) }
            .eraseToAnyPublisher()
    }

}
