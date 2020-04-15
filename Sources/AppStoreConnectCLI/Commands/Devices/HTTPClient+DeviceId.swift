// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import Combine

extension HTTPClient {

    enum DeviceIDError: Error, LocalizedError {
        case notUnique(String)

        var failureReason: String? {
            switch self {
            case .notUnique(let identifier):
                return "'\(identifier)' is not a unique Device UDID."
            }
        }
    }

    /// Find the opaque internal resource identifier for a Device  matching `udid`. Use this for reading, modifying and deleting Device resources.
    ///
    /// - parameter udid: The device UDID string.
    /// - returns: The App Store Connect API resource identifier for the Device UDID.
    func deviceUDIDResourceId(matching udid: String) throws -> AnyPublisher<String, Error> {
        let request = APIEndpoint.listDevices(
            filter: [
                .udid([udid])
            ]
        )

        return self.request(request)
            .map { $0.data.filter { $0.attributes.udid == udid } }
            .tryMap { response -> String in
                guard response.count == 1 else {
                    throw DeviceIDError.notUnique(udid)
                }
                return response.first!.id
            }
            .eraseToAnyPublisher()
    }
}
