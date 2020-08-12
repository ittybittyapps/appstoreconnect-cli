// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListProfilesByBundleIdOperation: APIOperation {

    struct Options {
        let bundleIdResourceId: String
        let limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[Profile], Error> {

        let endpoint: APIEndpoint<ProfilesResponse> = .listAllProfilesForBundleId(
            id: options.bundleIdResourceId,
            limit: options.limit
        )

        return requestor
            .request(endpoint)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
