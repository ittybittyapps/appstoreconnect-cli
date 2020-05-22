// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct AddGroupsToBuildOperation: APIOperation {

    struct Options {
        let groupIds: [String]
        let buildId: String
    }

    private let options: Options

    var endpoint: APIEndpoint<Void> {
        .add(accessForBetaGroupsWithIds: options.groupIds, toBuildWithId: options.buildId)
    }

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        requestor
            .request(endpoint)
            .eraseToAnyPublisher()
    }
}
