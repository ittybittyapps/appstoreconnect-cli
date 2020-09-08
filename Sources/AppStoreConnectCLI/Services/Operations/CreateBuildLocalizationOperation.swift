// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct CreateBuildLocalizationOperation: APIOperation {
    struct Options {
        let buildId: String
        let locale: String
        let whatsNew: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaBuildLocalization, Error> {
        requestor.request(
            .create(
                betaBuildLocalizationForBuildWithId: options.buildId,
                locale: options.locale,
                whatsNew: options.whatsNew
            )
        )
        .map(\.data)
        .eraseToAnyPublisher()
    }
}
