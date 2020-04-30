// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

protocol EndpointRequestor {
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Future<T, Error>
    func request(_ endpoint: APIEndpoint<Void>) -> Future<Void, Error>
}

struct DefaultEndpointRequestor: EndpointRequestor {
    let provider: APIProvider

    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Future<T, Error> {
        Future { [provider] promise in
            provider.request(endpoint, completion: promise)
        }
    }

    func request(_ endpoint: APIEndpoint<Void>) -> Future<Void, Error> {
        Future { [provider] promise in
            provider.request(endpoint, completion: promise)
        }
    }
}
