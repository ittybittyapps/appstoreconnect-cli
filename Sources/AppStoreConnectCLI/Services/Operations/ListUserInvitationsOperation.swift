// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Combine
import Foundation

struct ListUserInvitationsOperation: APIOperationV2 {

    struct Options {
        let filterEmail: [String]
        let filterRole: [ListUserInvitationsV1.Filter.Roles]
        let includeVisibleApps: Bool
        let limitVisibleApps: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with service: BagbutikService) async throws -> [UserInvitation] {
        var filters = [ListUserInvitationsV1.Filter]()

        if options.filterEmail.isNotEmpty { filters.append(.email(options.filterEmail)) }
        if options.filterRole.isNotEmpty { filters.append(.roles(options.filterRole)) }

        let limits = options.limitVisibleApps.map { [ListUserInvitationsV1.Limit.visibleApps($0)] }

        return try await service.requestAllPages(.listUserInvitationsV1(filters: filters, limits: limits)).data
    }
}

