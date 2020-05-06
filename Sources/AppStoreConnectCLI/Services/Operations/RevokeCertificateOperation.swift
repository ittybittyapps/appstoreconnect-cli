// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct RevokeCertificatesOperation: APIOperation {

    struct Options {
        let ids: [String]
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Void, Error> {
        let requests = options.ids.map {
            requestor.request(APIEndpoint.revokeCertificate(withId: $0))
        }

        return Publishers.ConcatenateMany(requests).eraseToAnyPublisher()
    }

}
