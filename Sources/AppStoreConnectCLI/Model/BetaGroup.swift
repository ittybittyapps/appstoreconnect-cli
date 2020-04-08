// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

extension HTTPClient {
    private enum BetaGroupError: Error, CustomStringConvertible {
        case couldntFindBetaGroup

        var description: String {
            switch self {
                case .couldntFindBetaGroup:
                    return "Couldn't find beta group with input name or group name not unique"
            }
        }
    }

    /// Find the opaque internal identifier for this beta group; search by group name.
    ///
    /// This is an App Store Connect internal identifier
    func betaGroupIdentifier(matching name: String) throws -> AnyPublisher<String, Error> {
        let endpoint = APIEndpoint.betaGroups(
            filter: [ListBetaGroups.Filter.name([name])]
        )

        return self.request(endpoint)
            .tryMap { response throws -> String in
                guard response.data.count == 1, let id = response.data.first?.id else {
                    throw BetaGroupError.couldntFindBetaGroup
                }

                return id
            }
            .eraseToAnyPublisher()
    }
}
