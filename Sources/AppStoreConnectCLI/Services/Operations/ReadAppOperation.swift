// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadAppOperation: APIOperation {

    struct Options {
        let id: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<AppStoreConnect_Swift_SDK.App, Swift.Error> {
        requestor.request(.app(withId: options.id))
            .map(\.data)
            .eraseToAnyPublisher()
    }

}
