// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBundleIdOperation: APIOperation {

    struct Options {
        let bundleId: String
    }

    enum Error: LocalizedError {
        case couldNotFindBundleId(String)
        case bundleIdNotUnique(String)

        var errorDescription: String? {
            switch self {
            case .couldNotFindBundleId(let bundleId):
                return "Couldn't find bundleId: '\(bundleId)'."
            case .bundleIdNotUnique(let serial):
                return "The bundleId your provided '\(serial)' is not unique."
            }
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BundleId, Swift.Error> {
        requestor.request(
            .listBundleIds(
                filter: [.identifier([options.bundleId])]
            )
        )
        .tryMap {
            switch $0.data.count {
            case 0:
                throw Error.couldNotFindBundleId(self.options.bundleId)
            case 1:
                return $0.data.first!
            default:
                throw Error.bundleIdNotUnique(self.options.bundleId)
            }
        }
        .eraseToAnyPublisher()
    }

}
