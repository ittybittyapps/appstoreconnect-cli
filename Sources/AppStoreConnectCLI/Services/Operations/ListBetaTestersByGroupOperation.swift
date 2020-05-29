// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListBetaTestersByGroupOperation: APIOperation {

    struct Options {
        let groupId: String
    }

    private let options: Options

    typealias BetaTester =  AppStoreConnect_Swift_SDK.BetaTester
    typealias Output = [BetaTester]

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Error> {
        let endpoint = APIEndpoint.betaTesters(inBetaGroupWithId: options.groupId)

        return requestor.request(endpoint)
        .map{ response -> Output in
            return response.data 
        }
        .eraseToAnyPublisher()
    }
}
