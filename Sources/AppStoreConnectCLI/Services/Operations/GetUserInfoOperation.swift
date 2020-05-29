// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.User

struct GetUserInfoOperation: APIOperation {

    enum Error: LocalizedError {
        case couldNotFindUser(email: String)

        var failureReason: String? {
            switch self {
            case .couldNotFindUser(let email):
                return "Couldn't find user with input email: '\(email)' or email not unique"
            }
        }
    }

    struct Options {
        let email: String
    }

    let options: Options

    private let endpoint: APIEndpoint<UsersResponse>

    init(options: Options) {
        let filters: [ListUsers.Filter] = [.username([options.email])]
        endpoint = APIEndpoint.users(filter: filters)
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<User, Swift.Error> {
        requestor.request(endpoint)
            .tryMap { [options] response in
                let users = User.fromAPIResponse(response)
                guard let user = users.first, users.count == 1 else {
                    throw Error.couldNotFindUser(email: options.email)
                }

                return user
            }
            .eraseToAnyPublisher()
    }

}
