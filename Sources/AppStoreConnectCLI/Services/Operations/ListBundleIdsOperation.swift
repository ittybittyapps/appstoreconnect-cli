// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListBundleIdsOperation: APIOperation {
    struct Options {
        let identifiers: [String]
        let names: [String]
        let platforms: [String]
        let seedIds: [String]
        let limit: Int?

        fileprivate var endpoint: APIEndpoint<BundleIdsResponse> {
            var filters: [BundleIds.Filter] = []

            if identifiers.isEmpty == false {
                filters.append(.identifier(identifiers))
            }

            if names.isEmpty == false {
                filters.append(.name(names))
            }

            if platforms.isEmpty == false {
                filters.append(.platform(platforms.compactMap(Platform.init(rawValue:))))
            }

            if seedIds.isEmpty == false {
                filters.append(.seedId(seedIds))
            }

            return .listBundleIds(filter: filters, limit: limit)
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    typealias BundleId = AppStoreConnect_Swift_SDK.BundleId

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[BundleId], Error> {
        requestor.request(options.endpoint).map(\.data).eraseToAnyPublisher()
    }
}
