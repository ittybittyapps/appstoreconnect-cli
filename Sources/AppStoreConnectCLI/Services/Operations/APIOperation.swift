// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine
import Foundation

protocol APIOperation {
    associatedtype Options
    associatedtype Output

    init(options: Options)

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Error>
}

protocol APIOperationV2 {
    associatedtype Options
    associatedtype Output
    associatedtype Service

    init(options: Options)

    func execute(with service: Service) async throws -> Output
}
