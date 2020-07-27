// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTestersByGroupOperation: APIOperation {

    struct Options {
        let groupId: String
    }

    private let options: Options

    typealias BetaTester = AppStoreConnect_Swift_SDK.BetaTester
    typealias Output = [BetaTester]

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Swift.Error> {
        requestor.requestAllPages {
            .betaTesters(inBetaGroupWithId: self.options.groupId, next: $0)
        }
        .map { $0.flatMap(\.data) }
        .eraseToAnyPublisher()
    }
}
