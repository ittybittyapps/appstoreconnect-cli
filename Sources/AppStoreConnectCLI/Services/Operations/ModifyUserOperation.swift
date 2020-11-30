// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyUserOperation: APIOperation {

    struct Options {
        let userId: String
        let allAppsVisible: Bool
        let provisioningAllowed: Bool
        let roles: [UserRole]
        let appsVisibleIds: [String]
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<User, Error> {
        let buildModifyEndpoint = APIEndpoint.modify(
            userWithId: options.userId,
            allAppsVisible: options.allAppsVisible,
            provisioningAllowed: options.provisioningAllowed,
            roles: options.roles,
            appsVisibleIds: options.appsVisibleIds
        )

        return requestor.request(buildModifyEndpoint)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
