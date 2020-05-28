// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListAppsOperation: APIOperation {

    struct Options {
        let bundleIds: [String]
        let names: [String]
        let skus: [String]
        let limit: Int?

        fileprivate var endpoint: APIEndpoint<AppsResponse> {
            var filters: [ListApps.Filter] = []
            bundleIds.isEmpty ? () : filters.append(.bundleId(bundleIds))
            names.isEmpty ? () : filters.append(.name(names))
            skus.isEmpty ? () : filters.append(.sku(skus))

            let limits = limit.map { [ListApps.Limit.apps($0)] }

            return .apps(filters: filters, limits: limits)
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    typealias App = AppStoreConnect_Swift_SDK.App

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[App], Error> {
        requestor.request(options.endpoint).map(\.data).eraseToAnyPublisher()
    }

}
