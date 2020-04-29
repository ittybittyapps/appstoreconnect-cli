// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

enum CertificatesError: LocalizedError {
    case invalidPath(String)
    case noContent

    var errorDescription: String? {
        switch self {
        case .invalidPath(let path):
            return "Download failed, please check the path '\(path)' you input and try again."
        case .noContent:
            return "The certificate in the response doesn't have a proper content."
        }
    }
}
