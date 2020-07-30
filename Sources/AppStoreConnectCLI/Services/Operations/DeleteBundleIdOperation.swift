// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DeleteBundleIdOperation: APIOperation {

    struct Options {
        let resourceId: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    var endpoint: APIEndpoint<Void> {
        .delete(
            bundleWithId: options.resourceId
        )
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        requestor
            .request(endpoint)
            .eraseToAnyPublisher()
    }
}
