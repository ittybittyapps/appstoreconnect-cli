// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetUserInfoOperation: APIOperation {

    enum GetUserInfoError: LocalizedError {
        case couldNotFindUser(email: String)

        var failureReason: String? {
            switch self {
            case .couldNotFindUser(let email):
                return "Couldn't find user with input email: '\(email)' or email not unique"
            }
        }
    }

    private let endpoint: APIEndpoint<UsersResponse>
    private let email: String

    init(options: GetUserInfoOptions) {
        let filters: [ListUsers.Filter] = [.username([options.email])]
        endpoint = APIEndpoint.users(filter: filters)
        email = options.email
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<User, Error> {
        requestor.request(endpoint)
            .tryMap { [email] response in
                let users = User.fromAPIResponse(response)
                guard let user = users.first, users.count == 1 else {
                    throw GetUserInfoError.couldNotFindUser(email: email)
                }

                return user
            }
            .eraseToAnyPublisher()
    }

}
