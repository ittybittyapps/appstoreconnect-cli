// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTestersOperation: APIOperation {

    struct Options {
        let email: String?
        let firstName: String?
        let lastName: String?
        let inviteType: BetaInviteType?
        let appIds: [String]?
        let groupIds: [String]?
        let sort: ListBetaTesters.Sort?
        let limit: Int?
        let relatedResourcesLimit: Int?
    }

    enum Error: LocalizedError {
        case notFound

        var errorDescription: String? {
            switch self {
            case .notFound:
                return "Beta testers with provided filters not found."
            }
        }
    }

    private let options: Options

    typealias Output = [GetBetaTesterOperation.Output]

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Swift.Error> {
        var limits: [ListBetaTesters.Limit] {
            var limits: [ListBetaTesters.Limit] = []

            if let resourcesLimit = options.relatedResourcesLimit {
                limits.append(.apps(resourcesLimit))
                limits.append(.betaGroups(resourcesLimit))
            }

            if let limit = options.limit {
                limits.append(.betaTesters(limit))
            }

            return limits
        }

        var sorts: [ListBetaTesters.Sort] {
            var sorts: [ListBetaTesters.Sort] = []

            if let sort = options.sort {
                sorts.append(sort)
            }

            return sorts
        }

        var filters: [ListBetaTesters.Filter] {
            var filters: [ListBetaTesters.Filter] = []

            if let firstName = options.firstName {
                filters.append(.firstName([firstName]))
            }

            if let lastName = options.lastName {
                filters.append(.lastName([lastName]))
            }

            if let email = options.email {
                filters.append(.email([email]))
            }

            if let inviteType = options.inviteType {
                filters.append(.inviteType([inviteType.rawValue]))
            }

            if let appIds = options.appIds, !appIds.isEmpty {
                filters.append(.apps(appIds))
            }

            if let groupIds = options.groupIds, !groupIds.isEmpty {
                filters.append(.betaGroups(groupIds))
            }

            return filters
        }

        var endpoint: APIEndpoint<BetaTestersResponse> {
            .betaTesters(
                filter: filters,
                include: [.apps, .betaGroups],
                limit: limits,
                sort: sorts
            )
        }

        return requestor.request(endpoint)
            .tryMap { (response: BetaTestersResponse) -> Output in
                guard !response.data.isEmpty else {
                    throw Error.notFound
                }

                return response.data.map {
                    .init(betaTester: $0, includes: response.included)
                }
            }
            .eraseToAnyPublisher()
    }

}
