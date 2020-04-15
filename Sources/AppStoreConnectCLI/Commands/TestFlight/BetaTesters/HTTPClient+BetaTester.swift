// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

extension HTTPClient {

    private enum BetaTesterError: Error, CustomStringConvertible {
        case couldntFindBetaTester

        var description: String {
            switch self {
                case .couldntFindBetaTester:
                    return "Couldn't find beta tester with input email or tester email not unique"
            }
        }
    }

    /// Find the opaque internal identifier for this tester; search by email adddress.
    ///
    /// This is an App Store Connect internal identifier
    func betaTesterResourceId(matching email: String) throws -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.betaTesters(
            filter: [ListBetaTesters.Filter.email([email])]
        )

        return self.request(endpoint)
            .tryMap { response throws -> String in
                guard response.data.count == 1, let id = response.data.first?.id else {
                    throw BetaTesterError.couldntFindBetaTester
                }

                return id
            }
            .eraseToAnyPublisher()
    }

}
