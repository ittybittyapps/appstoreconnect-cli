// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {
    struct CreateBetaGroupDependencies {
        let apps: (APIEndpoint<AppsResponse>) -> Future<AppsResponse, Error>
        let createBetaGroup: (APIEndpoint<BetaGroupResponse>) -> Future<BetaGroupResponse, Error>
    }

    private let groupName: String
    private let getAppIdsOperation: GetAppIdsOperation

    init(options: CreateBetaGroupOptions) {
        groupName = options.groupName
        getAppIdsOperation = GetAppIdsOperation(options: .init(bundleIds: [options.appBundleId]))
    }

    func execute(with dependencies: CreateBetaGroupDependencies) -> AnyPublisher<BetaGroup, Error> {
        let appId = getAppIdsOperation
            .execute(with: .init(apps: dependencies.apps))
            .compactMap(\.first)

        let createBetaGroupEndpoint = appId.map { appId -> APIEndpoint<BetaGroupResponse> in
            .create(betaGroupForAppWithId: appId, name: self.groupName)
        }

        let betaGroup = createBetaGroupEndpoint.flatMap(dependencies.createBetaGroup).map(\.data)

        return betaGroup.eraseToAnyPublisher()
    }
}
