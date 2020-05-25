// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct InviteTesterOperation: APIOperation {

    private enum InviteTesterError: LocalizedError {
        case noGroupsExist(groupNames: [String], bundleId: String)
        case noAppExist

        var errorDescription: String? {
            switch self {
            case .noGroupsExist(let groupNames, let bundleId):
                return "One or more of beta groups \"\(groupNames)\" don't exist or don't belong to application with bundle ID \"\(bundleId)\"."
            case .noAppExist:
                return "App with provided bundleId doesn't exist."
            }
        }
    }

    struct Options {
        let firstName: String?
        let lastName: String?
        let email: String
        let bundleId: String
        let groupNames: [String]
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<AppStoreConnect_Swift_SDK.BetaTester, Error> {
        let appIds = try GetAppsOperation(
                options: .init(bundleIds: [options.bundleId])
            )
            .execute(with: requestor)
            .await()
            .map { $0.id }

        guard let appId = appIds.first else {
            throw InviteTesterError.noAppExist
        }

        let betaGroups = try requestor
            .request(.betaGroups(forAppWithId: appId))
            .await()
            .data
        
        guard Set(options.groupNames).isSubset(of:
            Set(betaGroups.compactMap { $0.attributes?.name })) else {
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

            return requestor
                .request(endpoint)
                .eraseToAnyPublisher()
        }

        return Publishers.ConcatenateMany(requests)
            .last()
            .map(\.data)
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
