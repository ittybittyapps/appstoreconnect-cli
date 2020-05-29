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
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    typealias BundleId = AppStoreConnect_Swift_SDK.BundleId

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[BundleId], Error> {
        let platforms = options.platforms.compactMap(Platform.init(rawValue:))

        var filters: [BundleIds.Filter] = []
        filters += options.identifiers.isEmpty ? [] : [.identifier(options.identifiers)]
        filters += options.names.isEmpty ? [] : [.name(options.names)]
        filters += options.platforms.isEmpty ? [] : [.platform(platforms)]
        filters += options.seedIds.isEmpty ? [] : [.seedId(options.seedIds)]

        let limit = options.limit

        return requestor.requestAllPages {
                .listBundleIds(filter: filters, limit: limit, next: $0)
            }
            .map {
                $0.flatMap(\.data)
            }
            .eraseToAnyPublisher()
    }
}

extension BundleIdsResponse: PaginatedResponse { }
