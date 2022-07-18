// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import struct Model.User

struct ListUsersOperation: APIOperationV2 {
    typealias Output = [Bagbutik.User]
    
    typealias Filter = ListUsersV1.Filter
    typealias Limit = ListUsersV1.Limit
    typealias Include = ListUsersV1.Include

    struct Options {
        let limitVisibleApps: Int?
        let limitUsers: Int?
        let sort: String?
        let filterUsername: [String]
        let filterRole: [String]
        let filterVisibleApps: [String]
        let includeVisibleApps: Bool
    }

    private var limits: [Limit]? {
        [options.limitUsers.map(Limit.limit), options.limitVisibleApps.map(Limit.visibleApps)]
        .compactMap { $0 }
        .nilIfEmpty()
    }

    private var includes: [Include]? {
        options.includeVisibleApps ? [ListUsersV1.Include.visibleApps] : nil
    }

    private var filters: [Filter]? {
        let roles = options.filterRole.compactMap(Filter.Roles.init(rawValue:)).nilIfEmpty().map(Filter.roles)
        let usernames = options.filterUsername.nilIfEmpty().map(Filter.username)
        let visibleApps = options.filterVisibleApps.nilIfEmpty().map(Filter.visibleApps)

        return [roles, usernames, visibleApps].compactMap({ $0 }).nilIfEmpty()
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with service: BagbutikService) async throws -> Output {
        let sorts = options.sort.flatMap { ListUsersV1.Sort(rawValue: $0) }.map { [$0] }

        return try await service.requestAllPages(.listUsersV1(filters: filters, includes: includes, sorts: sorts, limits: limits)).data
    }
}

