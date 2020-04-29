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

    typealias App = AppStoreConnect_Swift_SDK.App
    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<ExtendedBetaGroup, Error> {
        let app = getAppsOperation
            .execute(with: requestor)
            .compactMap(\.first)

        let betaGroup = app.flatMap { app -> AnyPublisher<ExtendedBetaGroup, Error> in
            requestor
                .request(self.createBetaGroupEndpoint(app.id))
                .map { ExtendedBetaGroup(app: app, betaGroup: $0.data) }
                .eraseToAnyPublisher()
        }

        return betaGroup.eraseToAnyPublisher()
    }
}
