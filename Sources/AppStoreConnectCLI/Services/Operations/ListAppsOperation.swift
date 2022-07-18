// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Combine

struct ListAppsOperation: APIOperationV2 {

    struct Options {
        var bundleIds: [String] = []
        var names: [String] = []
        var skus: [String] = []
        var limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }
   
    func execute(with service: BagbutikService) async throws -> [App] {
        var filters: [ListAppsV1.Filter] = []

        if options.bundleIds.isNotEmpty { filters.append(.bundleId(options.bundleIds)) }
        if options.names.isNotEmpty { filters.append(.name(options.names)) }
        if options.skus.isNotEmpty { filters.append(.sku(options.skus)) }

        let limits = options.limit.map { [ListAppsV1.Limit.limit($0)] }
        
        guard limits != nil else {
            return try await service.requestAllPages(.listAppsV1(filters: filters)).data
        }

        return try await service
            .request(.listAppsV1(filters: filters, limits: limits))
            .data
    }

}
