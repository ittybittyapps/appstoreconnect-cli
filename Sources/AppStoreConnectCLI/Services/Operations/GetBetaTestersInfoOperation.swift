// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaTestersInfoOperation: APIOperation {

    struct Options {
        let email: String
        var limitApps: Int?
        var limitBuilds: Int?
        var limitBetaGroups: Int?
    }

    private enum Error: LocalizedError {
        case betaTesterNotFound(String)

        var errorDescription: String? {
            switch self {
            case .betaTesterNotFound(let email):
                return "Beta tester with provided email '\(email)' doesn't exist."
            }
        }
    }

    private var endpoint: APIEndpoint<BetaTestersResponse> {
        var limits: [ListBetaTesters.Limit] = []

        if let limitApps = options.limitApps {
            limits.append(.apps(limitApps))
        }

        if let limitBuilds = options.limitBuilds {
            limits.append(.builds(limitBuilds))
        }

        if let limitBetaGroups = options.limitBetaGroups {
            limits.append(.betaGroups(limitBetaGroups))
        }

        return APIEndpoint.betaTesters(
            filter: [.email([options.email])],
            include: [.betaGroups, .apps],
            limit: limits
        )
    }

    let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<BetaTestersResponse, Swift.Error> {
        requestor.request(endpoint)
            .tryMap { [email = options.email] (response: BetaTestersResponse) -> BetaTestersResponse in
                guard !response.data.isEmpty else {
                    throw Error.betaTesterNotFound(email)
                }

                return response
            }
            .eraseToAnyPublisher()
    }

}
