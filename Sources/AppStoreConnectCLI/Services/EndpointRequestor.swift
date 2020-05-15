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

protocol PaginatedResponse: Decodable {
    var links: PagedDocumentLinks { get }
}

extension EndpointRequestor {
    func concatFetcher<T: PaginatedResponse>(_ endpointMaker: @escaping (PagedDocumentLinks?) -> APIEndpoint<T>, next: PagedDocumentLinks?) -> AnyPublisher<[T], Error> {
        self.request(endpointMaker(next)).flatMap { (response) -> AnyPublisher<[T], Error> in
            if response.links.next != nil {
                return self.concatFetcher(endpointMaker, next: response.links)
                    .flatMap {
                        Empty<[T], Error>()
                            .append([response] + $0)
                    }
                    .eraseToAnyPublisher()
            }

            return Empty<[T], Error>().append([response]).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
