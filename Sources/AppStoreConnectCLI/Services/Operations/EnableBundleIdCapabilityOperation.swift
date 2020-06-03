// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct EnableBundleIdCapabilityOperation: APIOperation {

    struct Options {
        let bundleIdResourceId: String
        let capabilityType: CapabilityType
    }

    let option: Options

    init(options: Options) {
        self.option = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BundleIdCapabilityResponse, Error> {
        requestor
            .request(
                .enableCapability(
                    id: option.bundleIdResourceId,
                    capabilityType: option.capabilityType
                )
            )
            .eraseToAnyPublisher()
    }

}
