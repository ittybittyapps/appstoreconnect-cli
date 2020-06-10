// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct DisableCapabilityOperation: APIOperation {

    struct Options {
        let capabilityId: String
    }

    let option: Options

    init(options: Options) {
        self.option = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        requestor
            .request(
                .disableCapability(id: option.capabilityId)
            )
            .eraseToAnyPublisher()
    }

}
