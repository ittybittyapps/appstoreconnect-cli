// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

class AppStoreConnectService {
    private let provider: APIProvider

    init(configuration: APIConfiguration) {
        provider = APIProvider(configuration: configuration)
    }

    func listUsers(with options: ListUsersOptions) -> AnyPublisher<[User], Error> {
        let dependencies = ListUsersOperation.Dependencies(users: request)
        let operation = ListUsersOperation(options: options)

        return operation.execute(with: dependencies)
    }

    func getUserInfo(with options: GetUserInfoOptions) -> AnyPublisher<User, Error> {
        let dependencies = GetUserInfoOperation.Dependencies(usersResponse: request)
        let operation = GetUserInfoOperation(options: options)

        return operation.execute(with: dependencies)
    }

    /// Make a request for something `Decodable`.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Future<T, Error>` that executes immediately (hot observable)
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Future<T, Error> {
        // We use dispatch group to make this blocking - due to the nature of the app as a CLI tool it is necessary for API calls to be blocking
        let dispatchGroup = DispatchGroup()
        return Future<T, Error> { [provider] promise in
            dispatchGroup.enter()
            provider.request(endpoint) { result in
                switch result {
                    case .success(let response):
                        promise(.success(response))
                    case .failure(let error):
                        promise(.failure(error))
                }
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
    }

    /// Make a request which does not return anything (ie. returns `Void`) when successful.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Future<Void, Error>` that executes immediately (hot observable)
    func request(_ endpoint: APIEndpoint<Void>) -> Future<Void, Error> {
        // We use dispatch group to make this blocking - due to the nature of the app as a CLI tool it is necessary for API calls to be blocking
        let dispatchGroup = DispatchGroup()
        return Future<Void, Error> { [provider] promise in
            dispatchGroup.enter()
            provider.request(endpoint) { result in
                switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                }
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
    }
}
