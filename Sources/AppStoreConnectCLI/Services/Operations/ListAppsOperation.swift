// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListAppsOperation: APIOperation {

    struct Options {
        let bundleIds: [String]
        let names: [String]
        let skus: [String]
        let limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    typealias App = AppStoreConnect_Swift_SDK.App

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[App], Error> {
        var filters: [ListApps.Filter] = []

        options.bundleIds.isEmpty ? () : filters.append(.bundleId(options.bundleIds))
        options.names.isEmpty ? () : filters.append(.name(options.names))
        options.skus.isEmpty ? () : filters.append(.sku(options.skus))

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
