// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListProfilesOperation: APIOperation {

    struct Options {
        let filterName: [String]
        let filterProfileState: ProfileState?
        let filterProfileType: [ProfileType]
        let sort: Profiles.Sort?
        let limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[Profile], Error> {

        var filters = [Profiles.Filter]()

        if !options.filterName.isEmpty {
            filters.append(.name(options.filterName))
        }

        if let filterProfileState = options.filterProfileState {
            filters.append(.profileState([filterProfileState]))
        }

        if !options.filterProfileType.isEmpty {
            filters.append(.profileType(options.filterProfileType))
        }

        let sort = [options.sort].compactMap { $0 }

        var limits = [Profiles.Limit]()
        
        if let limit = options.limit {
            limits.append(.profiles(limit))
        }

        let endpoint = APIEndpoint.listProfiles(
            filter: filters,
            include: [.bundleId, .certificates, .devices],
            sort: sort,
            limit: limits
        )

        return requestor
            .request(endpoint)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
