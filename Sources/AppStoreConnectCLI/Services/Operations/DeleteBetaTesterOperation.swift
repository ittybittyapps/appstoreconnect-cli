// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DeleteBetaTesterOperation: APIOperation {

    struct Options {
        let ids: [String]
    }

    private let endpoints: [APIEndpoint<Void>]

    init(options: Options) {
        endpoints = options.ids.map {
            APIEndpoint.delete(betaTesterWithId: $0)
        }
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        let requests = endpoints.map {
            requestor
                .request($0)
                .eraseToAnyPublisher()
        }

        return Publishers.ConcatenateMany(requests)
            .eraseToAnyPublisher()
    }

}
