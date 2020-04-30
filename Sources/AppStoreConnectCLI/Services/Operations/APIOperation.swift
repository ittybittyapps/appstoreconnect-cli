// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine
import Foundation

protocol APIOperation {
    associatedtype Options
    associatedtype Output

    init(options: Options)

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Error>
}
