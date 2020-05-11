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
    }

    typealias Build = AppStoreConnect_Swift_SDK.Build
    typealias Relationships = [AppStoreConnect_Swift_SDK.BuildRelationship]?
    typealias Output = ([(build: Build, relationships: Relationships)], links: PagedDocumentLinks)

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Error> {
        var filters = [ListBuilds.Filter]()
        filters += options.filterAppIds.isEmpty ? [] : [.app(options.filterAppIds)]
        filters += options.filterPreReleaseVersions.isEmpty ? [] : [.preReleaseVersionVersion(options.filterPreReleaseVersions)]
        filters += options.filterBuildNumbers.isEmpty ? [] : [.version(options.filterBuildNumbers)]
        filters += options.filterExpired.isEmpty ? [] : [.expired(options.filterExpired)]
        filters += options.filterProcessingStates.isEmpty ? [] : [.processingState(options.filterProcessingStates)]
        filters += options.filterBetaReviewStates.isEmpty ? [] :  [.betaAppReviewSubmissionBetaReviewState(options.filterBetaReviewStates)]

        let limit = options.limit.map { limit -> [ListBuilds.Limit] in
            [.individualTesters(limit), .betaBuildLocalizations(limit)]
        }

        let endpoint = APIEndpoint.builds(
            filter: filters,
            include: [.app, .betaAppReviewSubmission, .buildBetaDetail, .preReleaseVersion],
            limit: limit,
            sort: [ListBuilds.Sort.uploadedDateAscending]
        )

        return requestor.request(endpoint)
            .map { response -> Output in
                (response.data.map { ($0, response.included) }, response.links)
            }
            .eraseToAnyPublisher()
    }
}

extension ListBuildsOperation {
    static func fetchByURL(url: URL, with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Error> {
        requestor.request(url, T: BuildsResponse.self)
            .map { response -> Output in
                (response.data.map { ($0, response.included) }, response.links)
            }
            .eraseToAnyPublisher()
    }
}
