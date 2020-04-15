// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

extension HTTPClient {

    enum BundleIDError: Error, LocalizedError {
        case notUnique(String)

        var failureReason: String? {
            switch self {
            case .notUnique(let identifier):
                return "'\(identifier)' is not a unique Bundle Identifier."
            }
        }
    }

    /// Find the opaque internal identifier for a bundle ID matching `identifier`.  Use this for reading, modifying and deleting BundleId resources.
    /// - parameter identifier: The  reverse-DNS style Bundle Identifier.
    /// - returns: The App Store Connect API resource identifier for the Bundle Identifier.
    func bundleIdResourceId(matching identifier: String) throws -> AnyPublisher<String, Error> {
        let request = APIEndpoint.listBundleIds(
            filter: [
                BundleIds.Filter.identifier([identifier])
            ]
        )

        return self.request(request)
            .map { $0.data.filter { $0.attributes?.identifier == identifier } }
            .tryMap { response -> String in
                guard response.count == 1 else {
                    throw BundleIDError.notUnique(identifier)
                }
                return response.first!.id
            }
            .eraseToAnyPublisher()
    }

}
