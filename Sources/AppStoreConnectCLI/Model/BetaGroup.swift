// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

extension HTTPClient {
    private enum BetaGroupError: LocalizedError {
        case couldntFindBetaGroup(groupNames: [String])
        case betaGroupNotUnique(groupNames: [String])

        var failureReason: String? {
            switch self {
                case .couldntFindBetaGroup(let groupNames):
                    return "Couldn't find beta group with input names \(groupNames)"
                case .betaGroupNotUnique(let groupNames):
                    return "The group name you input \(groupNames) are not unique"
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
                guard !response.data.isEmpty else {
                    throw BetaGroupError.couldntFindBetaGroup(groupNames: [name])
                }

                guard response.data.count == 1, let id = response.data.first?.id else {
                    throw BetaGroupError.betaGroupNotUnique(groupNames: [name])
                }

                return id
            }
            .eraseToAnyPublisher()
    }

    func betaGroupIdentifiers(matching names: [String]) throws -> AnyPublisher<[String], Error> {
        let endpoint = APIEndpoint.betaGroups(
            filter: [ListBetaGroups.Filter.name(names)]
        )

        return self.request(endpoint)
            .tryMap { response throws -> [String] in
                guard !response.data.isEmpty else {
                    throw BetaGroupError.couldntFindBetaGroup(groupNames: names)
                }

                return response.data.map { $0.id }
            }
            .eraseToAnyPublisher()
    }
}
