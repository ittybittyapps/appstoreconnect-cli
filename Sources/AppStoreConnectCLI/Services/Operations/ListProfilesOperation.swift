// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListProfilesOperation: APIOperation {

    struct Options {
        let ids: [String]
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

        if options.filterName.isNotEmpty { filters.append(.name(options.filterName)) }
        if options.filterProfileType.isNotEmpty { filters.append(.profileType(options.filterProfileType)) }
        if let filterProfileState = options.filterProfileState { filters.append(.profileState([filterProfileState])) }
        if options.ids.isNotEmpty { filters.append(.id(options.ids)) }

        let limits: [Profiles.Limit]? = options.limit != nil ? [.profiles(options.limit!)] : nil

        let sort = [options.sort].compactMap { $0 }

        return requestor
            .requestAllPages {
                .listProfiles(
                    filter: filters,
                    include: [.bundleId, .certificates, .devices],
                    sort: sort,
                    limit: limits,
                    next: $0
                )
            }
            .map { $0.flatMap(\.data) }
            .eraseToAnyPublisher()
    }
}

extension ProfilesResponse: PaginatedResponse { }
