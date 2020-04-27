// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {

    private let options: CreateBetaGroupOptions
    private let getAppsOperation: GetAppsOperation

    init(options: CreateBetaGroupOptions) {
        self.options = options
        self.getAppsOperation = GetAppsOperation(options: .init(bundleIds: [options.appBundleId]))
    }

    private typealias AppAttributes = AppStoreConnect_Swift_SDK.App.Attributes
    private typealias BetaGroupAttributes = AppStoreConnect_Swift_SDK.BetaGroup.Attributes

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaGroup, Error> {
        let options = self.options

        let app = getAppsOperation
            .execute(with: requestor)
            .compactMap(\.first)

        let betaGroup = app.flatMap { app -> AnyPublisher<BetaGroup, Error> in
            var betaGroupModel = BetaGroup(appId: app.id)

            if let appAttributes = app.attributes {
                betaGroupModel.update(with: appAttributes)
            }

            let endpoint = APIEndpoint.create(
                betaGroupForAppWithId: app.id,
                name: options.groupName,
                publicLinkEnabled: options.publicLinkEnabled,
                publicLinkLimit: options.publicLinkLimit,
                publicLinkLimitEnabled: options.publicLinkLimit != nil
            )

            let betaGroupResponse = requestor.request(endpoint)

            let betaGroup = betaGroupResponse.map { response -> BetaGroup in
                if let attributes = response.data.attributes {
                    betaGroupModel.update(with: attributes)
                }

                return betaGroupModel
            }

            return betaGroup.eraseToAnyPublisher()
        }

        return betaGroup.eraseToAnyPublisher()
    }
}
