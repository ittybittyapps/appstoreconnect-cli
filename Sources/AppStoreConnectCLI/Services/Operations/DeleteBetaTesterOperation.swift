// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DeleteBetaTestersOperation: APIOperation {

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
        Publishers
            .ConcatenateMany(endpoints.map(requestor.request))
            .eraseToAnyPublisher()
    }

}
