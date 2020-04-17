// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

protocol APIOperation {
    associatedtype Options
    associatedtype Output

    init(options: Options)

    func execute(using provider: APIProvider) -> AnyPublisher<Output, Error>
}
