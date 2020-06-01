// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTestersByGroupOperation: APIOperation {

    struct Options {
        let groupId: String
    }

    enum Error: LocalizedError {
        case notFound

        var errorDescription: String? {
            switch self {
            case .notFound:
                return "Beta testers not found."
            }
        }
    }

    private let options: Options

    typealias BetaTester = AppStoreConnect_Swift_SDK.BetaTester
    typealias Output = [BetaTester]

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Swift.Error> {
        return requestor.requestAllPages {
            .betaTesters(inBetaGroupWithId: self.options.groupId,next: $0)
        }
        .tryMap{ (responses: [BetaTestersResponse]) throws -> Output in
            try responses.flatMap { (response: BetaTestersResponse) -> Output in
                guard !response.data.isEmpty else {
                    throw Error.notFound
                }

                return response.data
            }
        }
        .eraseToAnyPublisher()
    }
}
