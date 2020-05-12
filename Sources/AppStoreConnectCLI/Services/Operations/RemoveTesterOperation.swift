// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct RemoveTesterOperation: APIOperation {

    struct Options {
        enum RemoveStrategy {
            case removeTestersFromGroup(testerIds: [String], groupId: String)
            case removeTesterFromGroups(testerId: String, groupIds: [String])
        }

        let removeStrategy: RemoveStrategy
    }

    private let options: Options

    var endpoint: APIEndpoint<Void> {
        switch options.removeStrategy {
        case .removeTesterFromGroups(let testerId, let groupIds):
            return APIEndpoint.remove(betaTesterWithId: testerId, fromBetaGroupsWithIds: groupIds)
        case .removeTestersFromGroup(let testerIds, let groupId):
            return APIEndpoint.remove(betaTestersWithIds: testerIds, fromBetaGroupWithId: groupId)
        }
    }

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Void, Error> {
        requestor
            .request(endpoint)
            .eraseToAnyPublisher()
    }

}
