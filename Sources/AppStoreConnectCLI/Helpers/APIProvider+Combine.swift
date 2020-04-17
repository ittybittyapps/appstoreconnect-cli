// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

// This functionality is temporarily duplicated until we only need it in one spot
extension APIProvider {
    /// Make a request for something `Decodable`.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Deferred<Future<T, Error>>` that executes once subscribed to (cold observable)
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Deferred<Future<T, Swift.Error>> {
        return Deferred() {
            // We use dispatch group to make this blocking - due to the nature of the app as a CLI tool it is necessary for API calls to be blocking
            let dispatchGroup = DispatchGroup()
            return Future<T, Swift.Error> { promise in
                dispatchGroup.enter()
                self.request(endpoint) { result in
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
    func request(_ endpoint: APIEndpoint<Void>) -> Deferred<Future<Void, Swift.Error>> {
        return Deferred() {
            // We use dispatch group to make this blocking - due to the nature of the app as a CLI tool it is necessary for API calls to be blocking
            let dispatchGroup = DispatchGroup()
            return Future<Void, Swift.Error> { promise in
                dispatchGroup.enter()
                self.request(endpoint) { result in
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
