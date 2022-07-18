// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Combine

struct ListBundleIdsOperation: APIOperationV2 {
    struct Options {
        let identifiers: [String]
        let names: [String]
        let platforms: [String]
        let seedIds: [String]
        let limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with service: BagbutikService) async throws -> [BundleId] {
        let platforms = options.platforms.compactMap(ListBundleIdsV1.Filter.Platform.init(rawValue:))

        var filters: [ListBundleIdsV1.Filter] = []

        if options.identifiers.isNotEmpty { filters.append(.identifier(options.identifiers)) }
        if options.names.isNotEmpty { filters.append(.name(options.names)) }
        if options.platforms.isNotEmpty { filters.append(.platform(platforms)) }
        if options.seedIds.isNotEmpty { filters.append(.seedId(options.seedIds)) }

        guard let limit = options.limit else {
            return try await service.requestAllPages(.listBundleIdsV1(filters: filters)).data
        }

        return try await service.request(.listBundleIdsV1(filters: filters, limits: [.limit(limit)])).data
    }
}
