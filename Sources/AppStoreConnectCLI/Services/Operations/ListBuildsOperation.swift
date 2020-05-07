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

    typealias Output  = [(build: Build, relationships: Relationships)]

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Error> {
        var filters = [ListBuilds.Filter]()
        filters += options.filterAppIds.isEmpty ? [] : [ListBuilds.Filter.app(options.filterAppIds)]
        filters += options.filterPreReleaseVersions.isEmpty ? [] : [ListBuilds.Filter.preReleaseVersionVersion(options.filterPreReleaseVersions)]
        filters += options.filterBuildNumbers.isEmpty ? [] : [ListBuilds.Filter.version(options.filterBuildNumbers)]
        filters += options.filterExpired.isEmpty ? [] : [ListBuilds.Filter.expired(options.filterExpired)]
        filters += options.filterProcessingStates.isEmpty ? [] : [ListBuilds.Filter.processingState(options.filterProcessingStates)]
        filters += options.filterBetaReviewStates.isEmpty ? [] :  [ListBuilds.Filter.betaAppReviewSubmissionBetaReviewState(options.filterBetaReviewStates)]

        var limit: [ListBuilds.Limit]?

        if let optionLimit = options.limit {
            limit = [ListBuilds.Limit.individualTesters(optionLimit),
                     ListBuilds.Limit.betaBuildLocalizations(optionLimit)]
        }

        let endpoint = APIEndpoint.builds(
            filter: filters,
            include: [.app, .betaAppReviewSubmission, .buildBetaDetail, .preReleaseVersion],
            limit: limit,
            sort: [ListBuilds.Sort.uploadedDateAscending]
        )

        return requestor.request(endpoint)
            .map { (buildResponse) -> Output in
                return buildResponse.data.map {
                    return ($0, buildResponse.included)
                }
        }
        .eraseToAnyPublisher()
    }
}
