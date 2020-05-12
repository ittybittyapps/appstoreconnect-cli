// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct RemoveBuildFromGroupsOperation: APIOperation {

    struct Options {
        let buildId: String
        let groupIds: [String]
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    var endpoint: APIEndpoint<Void> {
        .remove(
            accessForBetaGroupsWithIds: options.groupIds,
            toBuildWithId: options.buildId
        )
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        requestor
            .request(endpoint)
            .eraseToAnyPublisher()
    }
}
