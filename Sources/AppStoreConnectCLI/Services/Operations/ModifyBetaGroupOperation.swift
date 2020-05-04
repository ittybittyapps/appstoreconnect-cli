// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBetaGroupOperation: APIOperation {
    struct Options {
        let id: String
        let name: String?
        let publicLinkEnabled: Bool?
        let publicLinkLimit: Int?
        let publicLinkLimitEnabled: Bool?
    }

    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<BetaGroup, Error> {
        let endpoint: APIEndpoint<BetaGroupResponse> = .modify(
            betaGroupWithId: options.id,
            name: options.name,
            publicLinkEnabled: options.publicLinkEnabled,
            publicLinkLimit: options.publicLinkLimit,
            publicLinkLimitEnabled: options.publicLinkLimitEnabled
        )

        let response = requestor.request(endpoint)

        return response.map(\.data).eraseToAnyPublisher()
    }
}
