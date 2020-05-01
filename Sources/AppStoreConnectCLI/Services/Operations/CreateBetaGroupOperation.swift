// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {

    struct Options {
        let app: AppStoreConnect_Swift_SDK.App
        let groupName: String
        let publicLinkEnabled: Bool
        let publicLinkLimit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<ExtendedBetaGroup, Error> {
        let endpoint = APIEndpoint.create(
            betaGroupForAppWithId: options.app.id,
            name: options.groupName,
            publicLinkEnabled: options.publicLinkEnabled,
            publicLinkLimit: options.publicLinkLimit,
            publicLinkLimitEnabled: options.publicLinkLimit != nil
        )

        return requestor
            .request(endpoint)
            .map { ExtendedBetaGroup(app: self.options.app, betaGroup: $0.data) }
            .eraseToAnyPublisher()
    }
}
