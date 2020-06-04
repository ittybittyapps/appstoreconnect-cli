// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListUserInvitationsOperation: APIOperation {

    struct Options {
        let filterEmail: [String]
        let filterRole: [UserRole]
        let includeVisibleApps: Bool
        let limitVisibleApps: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[UserInvitation], Error> {
        var filters = [ListInvitedUsers.Filter]()

        if options.filterEmail.isNotEmpty { filters.append(.email(options.filterEmail)) }
        if options.filterRole.isNotEmpty { filters.append(.roles(options.filterRole.map { $0.rawValue })) }

        let limit = options.limitVisibleApps.map { [ListInvitedUsers.Limit.visibleApps($0)] }

        return requestor.requestAllPages {
                .invitedUsers(
                    limit: limit,
                    filter: filters,
                    next: $0
                )
            }
            .map { $0.flatMap { $0.data } }
            .eraseToAnyPublisher()
    }
}

extension UserInvitationsResponse: PaginatedResponse { }
