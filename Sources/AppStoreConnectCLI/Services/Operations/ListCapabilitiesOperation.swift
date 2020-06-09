// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListCapabilitiesOperation: APIOperation {

    struct Options {
        let bundleIdResourceId: String
    }

    let option: Options

    init(options: Options) {
        self.option = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[BundleIdCapability], Error> {
        requestor
            .request(
                .listAllCapabilitiesForBundleId(id: option.bundleIdResourceId)
            )
            .map(\.data)
            .eraseToAnyPublisher()
    }

}
