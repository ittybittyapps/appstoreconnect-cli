// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaGroupsOperation: APIOperation {
    struct ListBetaGroupsDependencies {
        let betaGroups: (APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error>
    }

    enum ListBetaGroupsError: LocalizedError {
        case missingAppData(AppStoreConnect_Swift_SDK.BetaGroup)

        var errorDescription: String? {
            switch self {
            case .missingAppData(let betaGroup):
                return "Missing app data for beta group: \(betaGroup)"
            }
        }
    }

    private let endpoint: APIEndpoint<BetaGroupsResponse>

    init(options: ListBetaGroupsOptions) {
        let filters = options.appIds.isEmpty ? [] : [ListBetaGroups.Filter.app(options.appIds)]
        endpoint = .betaGroups(filter: filters, include: [.app])
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[BetaGroup], Error> {
        let response = requestor.request(endpoint)

        let betaGroups = response.tryMap { response -> [BetaGroup] in
            let apps = response.included?.reduce(
                into: [String: AppStoreConnect_Swift_SDK.App](),
                { result, relationship in
                    switch relationship {
                    case .app(let app): result[app.id] = app
                    default: break
                    }
                }
            )

            return try response.data.map { betaGroupResponse -> BetaGroup in
                guard
                    let appId = betaGroupResponse.relationships?.app?.data?.id,
                    let app = apps?[appId]
                else {
                    throw ListBetaGroupsError.missingAppData(betaGroupResponse)
                }

                var betaGroup = BetaGroup(appId: appId)
                betaGroup.update(with: app.attributes)
                betaGroup.update(with: betaGroupResponse.attributes)
                return betaGroup
            }
        }

        return betaGroups.eraseToAnyPublisher()
    }
}
