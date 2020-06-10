// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

extension EndpointRequestor {
    func request<T>(_ endpoint: APIEndpoint<T>) -> Future<T, Error> where T: Decodable {
        Future { $0(.failure(TestError.somethingBadHappened)) }
    }

    func request(_ endpoint: APIEndpoint<Void>) -> Future<Void, Error> {
        Future { $0(.failure(TestError.somethingBadHappened)) }
    }
}

struct OneEndpointTestRequestor<U: Decodable>: EndpointRequestor {
    let response: (APIEndpoint<U>) -> Future<U, Error>

    func request<T>(_ endpoint: APIEndpoint<T>) -> Future<T, Error> where T: Decodable {
        guard
            let endpoint = endpoint as? APIEndpoint<U>,
            let response = response(endpoint) as? Future<T, Error>
        else {
            return Future { $0(.failure(TestError.somethingBadHappened)) }
        }

        return response
    }
}

struct TwoEndpointTestRequestor<U: Decodable, V: Decodable>: EndpointRequestor {
    let response: (APIEndpoint<U>) -> Future<U, Error>
    let response2: (APIEndpoint<V>) -> Future<V, Error>

    func request<T>(_ endpoint: APIEndpoint<T>) -> Future<T, Error> where T: Decodable {
        if
            let endpoint = endpoint as? APIEndpoint<U>,
            let response = response(endpoint) as? Future<T, Error>
        {
            return response
        }

        if
            let endpoint = endpoint as? APIEndpoint<V>,
            let response = response2(endpoint) as? Future<T, Error>
        {
            return response
        }

        return Future { $0(.failure(TestError.somethingBadHappened)) }
    }
}

struct FailureTestRequestor: EndpointRequestor {}
