// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

class HTTPClient {
    private let provider: APIProvider

    init(configuration: APIConfiguration) {
        provider = APIProvider(configuration: configuration)
    }

    /// Returns a Deferred Future that executes once subscribed to
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Deferred<Future<T, Error>> {
        return Deferred() { [provider] in
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
}
