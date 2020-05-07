// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DeleteBetaGroupOperation: APIOperation {
    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    struct Options {
        let betaGroupId: String
    }

    let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        let endpoint = APIEndpoint.delete(betaGroupWithId: options.betaGroupId)

        return requestor.request(endpoint).eraseToAnyPublisher()
    }
}
