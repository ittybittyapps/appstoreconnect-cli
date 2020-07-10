// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTestersOperation: APIOperation {

    struct Options {
        var email: String?
        var firstName: String?
        var lastName: String?
        var inviteType: BetaInviteType?
        var appIds: [String]?
        var groupIds: [String]?
        var sort: ListBetaTesters.Sort?
        var limit: Int?
        var relatedResourcesLimit: Int?
    }

    private let options: Options

    typealias Output = [GetBetaTesterOperation.Output]

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

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Swift.Error> {
        let filters = self.filters
        let limits = self.limits
        let sorts = self.sorts
        let includes: [ListBetaTesters.Include] = [.apps, .betaGroups]

        return requestor.requestAllPages {
                .betaTesters(
                    filter: filters,
                    include: includes,
                    limit: limits,
                    sort: sorts,
                    next: $0
                )
            }
            .tryMap { (responses: [BetaTestersResponse]) throws -> Output in
                responses.flatMap { (response: BetaTestersResponse) -> Output in
                    return response.data.map {
                        .init(betaTester: $0, includes: response.included)
                    }
                }
            }
            .eraseToAnyPublisher()
    }

}

extension BetaTestersResponse: PaginatedResponse { }
