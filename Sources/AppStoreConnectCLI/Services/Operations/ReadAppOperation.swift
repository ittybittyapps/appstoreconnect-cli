// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadAppOperation: APIOperation {

    struct Options {
        let id: String
    }

    private var endpoint: APIEndpoint<AppStoreConnect_Swift_SDK.AppResponse> {
        APIEndpoint.app(withId: options.id, include: [GetApp.Relationship.betaGroups, GetApp.Relationship.preReleaseVersions])
    }

    struct Output {
        let app: AppStoreConnect_Swift_SDK.App
        let includes: [AppStoreConnect_Swift_SDK.AppRelationship]?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Swift.Error> {
        requestor.request(endpoint)
            .map { Output(app: $0.data, includes: $0.included) }
            .eraseToAnyPublisher()
    }

}
