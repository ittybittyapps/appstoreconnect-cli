// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListAppsOperation: APIOperation {

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

    typealias App = AppStoreConnect_Swift_SDK.App

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[App], Error> {
        var filters: [ListApps.Filter] = []

        if options.bundleIds.isNotEmpty { filters.append(.bundleId(options.bundleIds)) }
        if options.names.isNotEmpty { filters.append(.name(options.names)) }
        if options.skus.isNotEmpty { filters.append(.sku(options.skus)) }

        let limits = options.limit.map { [ListApps.Limit.apps($0)] }

        guard limits != nil else {
            return requestor.requestAllPages {
                .apps(filters: filters, next: $0)
            }
            .map { $0.flatMap(\.data) }
            .eraseToAnyPublisher()
        }

        return requestor.request(.apps(filters: filters, limits: limits))
            .map(\.data)
            .eraseToAnyPublisher()
    }

}

extension AppsResponse: PaginatedResponse { }
