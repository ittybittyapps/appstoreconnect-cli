// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import struct Model.User

struct ListUsersOperation: APIOperation {
    
    typealias Filter = ListUsers.Filter
    typealias Limit = ListUsers.Limit

    struct Options {
        let limitVisibleApps: Int?
        let limitUsers: Int?
        let sort: ListUsers.Sort?
        let filterUsername: [String]
        let filterRole: [UserRole]
        let filterVisibleApps: [String]
        let includeVisibleApps: Bool
    }
    
    var limit: [ListUsers.Limit]? {
        [options.limitUsers.map(Limit.users), options.limitVisibleApps.map(Limit.visibleApps)]
        .compactMap { $0 }
        .nilIfEmpty()
    }

    var include: [ListUsers.Include]? {
        options.includeVisibleApps ? [ListUsers.Include.visibleApps] : nil
    }

    var filter: [Filter]? {
        let roles = options.filterRole.map(\.rawValue).nilIfEmpty().map(Filter.roles)
        let usernames = options.filterUsername.nilIfEmpty().map(Filter.username)
        let visibleApps = options.filterVisibleApps.nilIfEmpty().map(Filter.visibleApps)

        return [roles, usernames, visibleApps].compactMap({ $0 }).nilIfEmpty()
    }

    let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[User], Error> {
        let include = self.include
        let limit = self.limit
        let sort = options.sort.map { [$0] }
        let filter = self.filter

        return requestor.requestAllPages {
            .users(
                include: include,
                limit: limit,
                sort: sort,
                filter: filter,
                next: $0
            )
        }
        .map { $0.flatMap(User.fromAPIResponse) }
        .eraseToAnyPublisher()
    }
}

extension UsersResponse: PaginatedResponse { }
