// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct AddTesterToGroupOperation: APIOperation {

    struct Options {
        enum AddStrategy {
            case addTestersToGroup(testerIds: [String], groupId: String)
            case addTesterToGroups(testerId: String, groupIds: [String])
        }

        let addStrategy: AddStrategy
    }

    private let options: Options

    var endpoint: APIEndpoint<Void> {
        switch options.addStrategy {
        case .addTestersToGroup(let testerIds, let groupId):
            return .add(betaTestersWithIds: testerIds, toBetaGroupWithId: groupId)
        case .addTesterToGroups(let testerId, let groupIds):
            return .add(betaTesterWithId: testerId, toBetaGroupsWithIds: groupIds)
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
