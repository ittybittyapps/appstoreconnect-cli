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
            let platforms = self.platforms.compactMap(Platform.init(rawValue:))

            var filters: [BundleIds.Filter] = []
            filters += identifiers.isEmpty ? [] : [.identifier(identifiers)]
            filters += names.isEmpty ? [] : [.name(names)]
            filters += platforms.isEmpty ? [] : [.platform(platforms)]
            filters += seedIds.isEmpty ? [] : [.seedId(seedIds)]

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
