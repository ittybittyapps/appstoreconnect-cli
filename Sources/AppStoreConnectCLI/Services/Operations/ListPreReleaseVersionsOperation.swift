// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListPreReleaseVersionsOperation: APIOperation {

    struct Options {
        var filterAppIds: [String] = []
        var filterVersions: [String] = []
        var filterPlatforms: [String] = []
        var sort: ListPrereleaseVersions.Sort?
    }

    typealias PreReleaseVersion =  AppStoreConnect_Swift_SDK.PrereleaseVersion
    typealias Relationships = [AppStoreConnect_Swift_SDK.PreReleaseVersionRelationship]?
    typealias Output = [(preReleaseVersion: PreReleaseVersion, relationships: Relationships)]

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Swift.Error> {
        var filters: [ListPrereleaseVersions.Filter] = []

        if options.filterAppIds.isNotEmpty { filters.append(.app(options.filterAppIds)) }
        if options.filterVersions.isNotEmpty { filters.append(.version(options.filterVersions)) }
        if options.filterPlatforms.isNotEmpty { filters.append(.platform(options.filterPlatforms.map { .init(rawValue: $0) ?? .IOS } )) }

        let sort = [options.sort].compactMap { $0 }

        return requestor.requestAllPages {
            .prereleaseVersions(
                filter: filters,
                include: [.app],
                sort: sort,
                next: $0
            )
        }
        .map {
            $0.flatMap { response -> Output in
                response.data.map { ($0, response.included) }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension PreReleaseVersionsResponse: PaginatedResponse { }
