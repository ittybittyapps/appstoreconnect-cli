// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine
import Foundation

protocol APIOperation {
    associatedtype Options
    associatedtype Dependencies
    associatedtype Output

    init(options: Options)

    func execute(with dependencies: Dependencies) -> AnyPublisher<Output, Error>
}
