// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {

    private let getAppsOperation: GetAppsOperation
    private let createBetaGroupEndpoint: (_ appId: String) -> APIEndpoint<BetaGroupResponse>

    init(options: CreateBetaGroupOptions) {
        getAppsOperation = GetAppsOperation(options: .init(bundleIds: [options.appBundleId]))
        createBetaGroupEndpoint = { appId in
            .create(
                betaGroupForAppWithId: appId,
                name: options.groupName,
                publicLinkEnabled: options.publicLinkEnabled,
                publicLinkLimit: options.publicLinkLimit,
                publicLinkLimitEnabled: options.publicLinkLimit != nil
            )
        }
    }

    private typealias AppAttributes = AppStoreConnect_Swift_SDK.App.Attributes
    private typealias BetaGroupAttributes = AppStoreConnect_Swift_SDK.BetaGroup.Attributes

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaGroup, Error> {
        let app = getAppsOperation
            .execute(with: requestor)
            .compactMap(\.first)

        let betaGroup = app.flatMap { app -> AnyPublisher<BetaGroup, Error> in
            var betaGroup = BetaGroup(appId: app.id)
            betaGroup.update(with: app.attributes)

            return requestor
                .request(self.createBetaGroupEndpoint(app.id))
                .map { response -> BetaGroup in
                    betaGroup.update(with: response.data.attributes)
                    return betaGroup
                }
                .eraseToAnyPublisher()
        }

        return betaGroup.eraseToAnyPublisher()
    }
}
