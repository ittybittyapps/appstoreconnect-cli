// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBundleIdOperation: APIOperation {

    struct Options {
        let resourceId: String
        let name: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    var endpoint: APIEndpoint<BundleIdResponse> {
        .modifyBundleId(
            id: options.resourceId,
            name: options.name
        )
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BundleIdResponse, Error> {
        requestor
            .request(endpoint)
            .eraseToAnyPublisher()
    }
}
