// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {
    struct CreateBetaGroupDependencies {
        let apps: (APIEndpoint<AppsResponse>) -> Future<AppsResponse, Error>
        let createBetaGroup: (APIEndpoint<BetaGroupResponse>) -> Future<BetaGroupResponse, Error>
    }

    private let options: CreateBetaGroupOptions
    private let getAppsOperation: GetAppsOperation

    init(options: CreateBetaGroupOptions) {
        self.options = options
        self.getAppsOperation = GetAppsOperation(options: .init(bundleIds: [options.appBundleId]))
    }

    private typealias AppAttributes = AppStoreConnect_Swift_SDK.App.Attributes
    private typealias BetaGroupAttributes = AppStoreConnect_Swift_SDK.BetaGroup.Attributes

    func execute(with dependencies: CreateBetaGroupDependencies) -> AnyPublisher<BetaGroup, Error> {
        let options = self.options

        let app = getAppsOperation
            .execute(with: .init(apps: dependencies.apps))
            .compactMap(\.first)

        let appAndGroupAttributes = app
            .flatMap { app -> AnyPublisher<(AppAttributes?, BetaGroupAttributes?), Error> in
                let endpoint = APIEndpoint.create(
                    betaGroupForAppWithId: app.id,
                    name: options.groupName,
                    publicLinkEnabled: options.publicLinkEnabled)

                let betaGroupResponse = dependencies.createBetaGroup(endpoint)

                return betaGroupResponse
                    .map({ (app.attributes, $0.data.attributes) })
                    .eraseToAnyPublisher()
            }

        let betaGroup = appAndGroupAttributes.map { appAttributes, groupAttributes -> BetaGroup in
            BetaGroup(
                appBundleId: appAttributes?.bundleId,
                appName: appAttributes?.name,
                groupName: groupAttributes?.name,
                isInternal: groupAttributes?.isInternalGroup,
                publicLink: groupAttributes?.publicLink,
                publicLinkEnabled: groupAttributes?.publicLinkEnabled,
                publicLinkLimit: groupAttributes?.publicLinkLimit,
                publicLinkLimitEnabled: groupAttributes?.publicLinkEnabled,
                creationDate: groupAttributes?.createdDate
            )
        }

        return betaGroup.eraseToAnyPublisher()
    }
}
