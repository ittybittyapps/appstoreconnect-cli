// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct InviteTesterOperation: APIOperation {

    struct InviteBetaTesterDependencies {
        let apps: (APIEndpoint<AppsResponse>) -> Future<AppsResponse, Error>
        let betaGroupsResponse: (APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error>
        let betaTesterResponse: (APIEndpoint<BetaTesterResponse>) -> Future<BetaTesterResponse, Error>
    }

    private enum InviteTesterError: LocalizedError {
        case noGroupsExist(groupNames: [String], bundleId: String)

        var errorDescription: String? {
            switch self {
            case .noGroupsExist(let groupNames, let bundleId):
                return "One or more of beta groups \"\(groupNames)\" don't exist or don't belong to application with bundle ID \"\(bundleId)\"."
            }
        }
    }

    private let options: InviteBetaTesterOptions

    private let getAppsOperation: GetAppsOperation

    init(options: InviteBetaTesterOptions) {
        self.options = options

        self.getAppsOperation = GetAppsOperation(options: .init(bundleIds: [options.bundleId]))
    }

    func execute(with dependencies: InviteBetaTesterDependencies) throws -> AnyPublisher<BetaTester, Error> {
        let appId = try getAppsOperation
            .execute(with: .init(apps: dependencies.apps))
            .await()
            .map { $0.id }
            .first!

        let betaGroups = try dependencies
            .betaGroupsResponse(APIEndpoint.betaGroups(forAppWithId: appId))
            .await()
            .data

        guard options.groupNames.isSubarray(of:
            betaGroups.compactMap { $0.attributes?.name }) else {
                throw InviteTesterError.noGroupsExist(
                    groupNames: options.groupNames,
                    bundleId: options.bundleId
                )
            }

        let groupIds = getGroupIds(in: betaGroups, matching: options.groupNames)

        let requests = groupIds.map { (id: String) -> AnyPublisher<BetaTesterResponse, Error> in
            let endpoint = APIEndpoint.create(
                betaTesterWithEmail: options.email,
                firstName: options.firstName,
                lastName: options.lastName,
                betaGroupIds: [id]
            )

            return dependencies
                .betaTesterResponse(endpoint)
                .eraseToAnyPublisher()
        }

        let testerId = try Publishers.ConcatenateMany(requests)
            .last()
            .await()
            .data
            .id

        return GetBetaTesterInfoOperation(
                options: GetBetaTesterInfoOptions(id: testerId)
            )
            .execute(
                with: .init(betaTesterResponse: dependencies.betaTesterResponse)
            )
            .eraseToAnyPublisher()
    }

    func getGroupIds(
        in betaGroups: [AppStoreConnect_Swift_SDK.BetaGroup],
        matching names: [String]
    ) -> [String] {
        betaGroups.filter { (betaGroup: AppStoreConnect_Swift_SDK.BetaGroup) in
            guard let name = betaGroup.attributes?.name else {
                return false
            }

            return options.groupNames.contains(name)
        }
        .map { $0.id }
    }

}
