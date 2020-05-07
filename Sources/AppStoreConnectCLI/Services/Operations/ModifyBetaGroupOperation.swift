// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBetaGroupOperation: APIOperation {
    struct Options {
        let betaGroup: BetaGroup
        let betaGroupName: String?
        let publicLinkEnabled: Bool?
        let publicLinkLimit: Int?
        let publicLinkLimitEnabled: Bool?
    }

    typealias App = AppStoreConnect_Swift_SDK.App
    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaGroup, Swift.Error> {
        let endpoint: APIEndpoint<BetaGroupResponse> = .modify(
            betaGroupWithId: options.betaGroup.id,
            name: options.betaGroupName,
            publicLinkEnabled: options.publicLinkEnabled,
            publicLinkLimit: options.publicLinkLimit,
            publicLinkLimitEnabled: options.publicLinkLimitEnabled
        )

        let response = requestor.request(endpoint)

        return response.map(\.data).eraseToAnyPublisher()
    }
}
