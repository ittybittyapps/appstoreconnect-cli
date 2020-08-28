// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct DeleteBuildLocalizationOperation: APIOperation {
    struct Options {
        let localizationId: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        requestor.request(
            .delete(betaBuildLocalizationWithId: options.localizationId)
        )
        .eraseToAnyPublisher()
    }
}
