// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

protocol EndpointRequestor {
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Future<T, Error>
    func request(_ endpoint: APIEndpoint<Void>) -> Future<Void, Error>
    
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) async throws -> T
    func request(_ endpoint: APIEndpoint<Void>) async throws
}

struct DefaultEndpointRequestor: EndpointRequestor {
    let provider: APIProvider

    func request<T>(_ endpoint: APIEndpoint<T>) async throws -> T where T : Decodable {
        try await withCheckedThrowingContinuation { cont in
            provider.request(endpoint) { result in
                cont.resume(with: result)
            }
        }
    }
    
    func request(_ endpoint: APIEndpoint<Void>) async throws {
        try await withCheckedThrowingContinuation { cont in
            provider.request(endpoint) { result in
                cont.resume(with: result)
            }
        }
    }
    
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

protocol PaginatedResponse: Decodable {
    var links: PagedDocumentLinks { get }
}

extension EndpointRequestor {
    func requestAllPages<T: PaginatedResponse>(
        with endpointProvider: @escaping (PagedDocumentLinks?) -> APIEndpoint<T>,
        next: PagedDocumentLinks? = nil
    ) -> AnyPublisher<[T], Error> {
        request(endpointProvider(next))
            .flatMap { (response) -> AnyPublisher<[T], Error> in
                guard response.links.next != nil else {
                    return Just([response]).setFailureType(to: Error.self).eraseToAnyPublisher()
                }

                return self.requestAllPages(with: endpointProvider, next: response.links)
                    .flatMap { Just([response] + $0).setFailureType(to: Error.self) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
