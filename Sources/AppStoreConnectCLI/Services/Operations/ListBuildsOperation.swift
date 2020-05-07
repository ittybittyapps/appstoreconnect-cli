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

    enum ListBuildsError: LocalizedError {
        case noBuildExist

        var errorDescription: String? {
            switch self {
            case .noBuildExist:
                return "No build exists"
            }
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[Build], Error> {

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
            .tryMap { (buildResponse) throws -> [Build] in
                guard !buildResponse.data.isEmpty else {
                    throw ListBuildsError.noBuildExist
                }

                let buildDetailsInfo = buildResponse.data.map {
                    Build($0, buildResponse.included)
                }

                return buildDetailsInfo
        }
        .eraseToAnyPublisher()
    }
}
