// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListBundleIdsOperation: APIOperation {
    struct Options {
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    typealias BundleId = AppStoreConnect_Swift_SDK.BundleId

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[BundleId], Error> {
        Empty().eraseToAnyPublisher()
    }
}
