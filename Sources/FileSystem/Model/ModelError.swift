// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

enum ModelError: LocalizedError {

    case missingBundleId(appId: String)

    var errorDescription: String? {
        switch self {
        case .missingBundleId(let appId):
            return "App with id: \(appId) is missing bundleId data"
        }
    }

}
