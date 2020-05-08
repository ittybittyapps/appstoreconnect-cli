// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadAppOperation: APIOperation {

    struct Options {
        let identifier: ReadAppCommand.Identifier
    }

    enum Error: LocalizedError {
        case notFound(String)
        case notUnique(String)

        var errorDescription: String? {
            switch self {
            case .notFound(let identifier):
                return "App with provided identifier '\(identifier)' doesn't exist."
            case .notUnique(let identifier):
                return "App with provided identifier '\(identifier)' not unique."
            }
        }
    }

    typealias App = AppStoreConnect_Swift_SDK.App

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<App, Swift.Error> {
        let result: AnyPublisher<App, Swift.Error>

        switch options.identifier {
        case .appId(let appId):
            result = requestor.request(.app(withId: appId))
                .map(\.data)
                .eraseToAnyPublisher()
        case .bundleId(let bundleId):
            let endpoint: APIEndpoint = .apps(filters: [.bundleId([bundleId])])

            result = requestor.request(endpoint)
                .tryMap { (response: AppsResponse) throws -> App in
                    switch response.data.count {
                    case 0:
                        throw Error.notFound(bundleId)
                    case 1:
                        return response.data.first!
                    default:
                        throw Error.notUnique(bundleId)
                    }
                }
                .eraseToAnyPublisher()
        }

        return result
    }

}
