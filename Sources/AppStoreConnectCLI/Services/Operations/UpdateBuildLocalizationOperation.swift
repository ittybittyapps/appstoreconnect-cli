// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct UpdateBuildLocalizationOperation: APIOperation {
    struct Options {
        let localizationId: String
        let whatsNew: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaBuildLocalization, Error> {
        requestor.request(
            .modify(
                betaBuildLocalizationWithId: options.localizationId,
                whatsNew: options.whatsNew
            )
        )
        .map(\.data)
        .eraseToAnyPublisher()
    }
}
