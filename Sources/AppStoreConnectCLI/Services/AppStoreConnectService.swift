// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

class AppStoreConnectService {
    private let provider: APIProvider

    init(configuration: APIConfiguration) {
        provider = APIProvider(configuration: configuration)
    }

    struct ListUsersOptions {
        let limitVisibleApps: Int?
        let limitUsers: Int?
        let sort: ListUsers.Sort?
        let filterUsername: [String]
        let filterRole: [UserRole]
        let filterVisibleApps: [String]
        let includeVisibleApps: Bool
    }

    func listUsers(with options: ListUsersOptions) -> AnyPublisher<[User], Error> {
        let include = options.includeVisibleApps ? [ListUsers.Include.visibleApps] : nil

        let limit = [
            options.limitUsers.map(ListUsers.Limit.users),
            options.limitVisibleApps.map(ListUsers.Limit.visibleApps)]
            .compactMap { $0 }
            .nilIfEmpty()

        let sort = options.sort.map { [$0] }

        typealias Filter = ListUsers.Filter

        let filter: [Filter]? = {
            let roles = options.filterRole.map({ $0.rawValue }).nilIfEmpty().map(Filter.roles)
            let usernames = options.filterUsername.nilIfEmpty().map(Filter.username)
            let visibleApps = options.filterVisibleApps.nilIfEmpty().map(Filter.visibleApps)

            return [roles, usernames, visibleApps].compactMap({ $0 }).nilIfEmpty()
        }()

        let endpoint = APIEndpoint.users(
            fields: nil,
            include: include,
            limit: limit,
            sort: sort,
            filter: filter,
            next: nil
        )

        return request(endpoint)
            .map(User.fromAPIResponse)
            .eraseToAnyPublisher()
    }

    /// Make a request for something `Decodable`.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Deferred<Future<T, Error>>` that executes once subscribed to (cold observable)
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Deferred<Future<T, Error>> {
        return Deferred() { [provider] in
            // We use dispatch group to make this blocking - due to the nature of the app as a CLI tool it is necessary for API calls to be blocking
            let dispatchGroup = DispatchGroup()
            return Future<T, Error> { promise in
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
    }

    /// Make a request which does not return anything (ie. returns `Void`) when successful.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Deferred<Future<Void, Error>>` that executes once subscribed to (cold observable)
    func request(_ endpoint: APIEndpoint<Void>) -> Deferred<Future<Void, Error>> {
        return Deferred() { [provider] in
            // We use dispatch group to make this blocking - due to the nature of the app as a CLI tool it is necessary for API calls to be blocking
            let dispatchGroup = DispatchGroup()
            return Future<Void, Error> { promise in
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
}

private extension Collection {
    func nilIfEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
