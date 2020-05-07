// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBuildsOperation: APIOperation {

    struct Options {
        let appId: [String]
        let expired: [String]
        let preReleaseVersion: [String]
        let buildNumber: [String]
        let betaReviewState: [String]
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

        if !options.appId.isEmpty {
            filters += [ListBuilds.Filter.app(options.appId)]
        }

        if !options.preReleaseVersion.isEmpty {
            filters += [ListBuilds.Filter.preReleaseVersionVersion(options.preReleaseVersion)]
        }

        if !options.buildNumber.isEmpty {
            filters += [ListBuilds.Filter.version(options.buildNumber)]
        }

        if !options.expired.isEmpty {
            filters += [ListBuilds.Filter.expired(options.expired)]
        }

        if !options.betaReviewState.isEmpty {
            filters += [ListBuilds.Filter.betaAppReviewSubmissionBetaReviewState(options.betaReviewState)]
        }

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
