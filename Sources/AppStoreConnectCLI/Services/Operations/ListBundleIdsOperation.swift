// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik

struct ListBundleIdsOperation: APIOperationV2 {
    struct Options {
        typealias Platform = ListBundleIdsV1.Filter.Platform
        
        let identifiers: [String]
        let names: [String]
        let platforms: [Platform]
        let seedIds: [String]
        let limit: Int?
    }

    private let service: BagbutikService
    private let options: Options
    
    init(service: BagbutikService, options: Options) {
        self.service = service
        self.options = options
    }
    
    func execute() async throws -> [BundleId] {
        var filters: [ListBundleIdsV1.Filter] = []

        if options.identifiers.isNotEmpty { filters.append(.identifier(options.identifiers)) }
        if options.names.isNotEmpty { filters.append(.name(options.names)) }
        if options.platforms.isNotEmpty { filters.append(.platform(options.platforms)) }
        if options.seedIds.isNotEmpty { filters.append(.seedId(options.seedIds)) }

        guard let limit = options.limit else {
            return try await service.requestAllPages(.listBundleIdsV1(filters: filters)).data
        }

        return try await service.request(.listBundleIdsV1(filters: filters, limits: [.limit(limit)])).data
    }
}
