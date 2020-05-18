// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListPreReleaseVersionsOperation: APIOperation {

    struct Options {
        var filterAppIds: [String] = []
        var filterVersions: [String] = []
        var filterPlatforms: [String] = []
        var sort: ListPrereleaseVersions.Sort? = nil
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
        filters += options.filterAppIds.isEmpty ? [] : [.app(options.filterAppIds)]
        filters += options.filterVersions.isEmpty ? [] : [.version(options.filterVersions)]
        filters += options.filterPlatforms.isEmpty ? [] : [.platform(options.filterPlatforms)]

        let endpoint = APIEndpoint.prereleaseVersions(
            filter: filters,
            include: [.app],
            sort: [options.sort].compactMap { $0 }
        )

        return requestor.request(endpoint)
            .map{ response -> Output in
                return response.data.map {($0, response.included)}
            }
            .eraseToAnyPublisher()
    }
}
