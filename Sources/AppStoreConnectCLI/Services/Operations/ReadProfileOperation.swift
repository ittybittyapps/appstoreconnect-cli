// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ReadProfileOperation: APIOperation {

    struct Options {
        let id: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Profile, Swift.Error> {
        requestor.request(
            .readProfileInformation(id: options.id)
        )
        .map(\.data)
        .eraseToAnyPublisher()
    }

}
