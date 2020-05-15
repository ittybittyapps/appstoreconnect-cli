// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBuildsOperation: APIOperation {

    struct Options {
        let filterAppIds: [String]
        let filterExpired: [String]
        let filterPreReleaseVersions: [String]
        let filterBuildNumbers: [String]
        let filterProcessingStates: [ListBuilds.Filter.ProcessingState]
        let filterBetaReviewStates: [String]
        let limit: Int?
        let resourceLimit: Int?
    }

    typealias Build = AppStoreConnect_Swift_SDK.Build
    typealias Relationships = [AppStoreConnect_Swift_SDK.BuildRelationship]?
    typealias Output = [(build: Build, relationships: Relationships)]

    var filters: [ListBuilds.Filter] {
        var filters = [ListBuilds.Filter]()
        filters += options.filterAppIds.isEmpty ? [] : [.app(options.filterAppIds)]
        filters += options.filterPreReleaseVersions.isEmpty ? [] : [.preReleaseVersionVersion(options.filterPreReleaseVersions)]
        filters += options.filterBuildNumbers.isEmpty ? [] : [.version(options.filterBuildNumbers)]
        filters += options.filterExpired.isEmpty ? [] : [.expired(options.filterExpired)]
        filters += options.filterProcessingStates.isEmpty ? [] : [.processingState(options.filterProcessingStates)]
        filters += options.filterBetaReviewStates.isEmpty ? [] :  [.betaAppReviewSubmissionBetaReviewState(options.filterBetaReviewStates)]

        return filters
    }

    var limit: [ListBuilds.Limit]? {
        var limit = options.resourceLimit.map { limit -> [ListBuilds.Limit] in
            [.individualTesters(limit), .betaBuildLocalizations(limit)]
        }

        if let buildLimit = options.limit {
            if var limit = limit {
                limit += [ListBuilds.Limit.builds(buildLimit)]
            } else {
                limit = [ListBuilds.Limit.builds(buildLimit)]
            }
        }

        return limit
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Error> {
        concatFetcher(with: requestor, next: nil)
            .map { (responses: [BuildsResponse]) -> Output in
                responses.flatMap { (response: BuildsResponse) -> Output in
                    (response.data.map { ($0, response.included) })
                }
            }
            .eraseToAnyPublisher()
    }

    func concatFetcher(with requestor: EndpointRequestor, next: PagedDocumentLinks?) -> AnyPublisher<[BuildsResponse], Error> {
        let endpoint = APIEndpoint.builds(
            filter: filters,
            include: [.app, .betaAppReviewSubmission, .buildBetaDetail, .preReleaseVersion],
            limit: limit,
            sort: [ListBuilds.Sort.uploadedDateAscending],
            next: next
        )

        return requestor.request(endpoint)
            .flatMap { [concatFetcher] (response) -> AnyPublisher<[BuildsResponse], Error> in
                if response.links.next != nil {
                    return concatFetcher(requestor, response.links)
                        .flatMap {
                            Empty<[BuildsResponse], Error>()
                                .append([response] + $0)
                        }
                        .eraseToAnyPublisher()
                }

                return Empty<[BuildsResponse], Error>().append([response]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
