// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

enum CommandError: LocalizedError {
    case unimplemented

    var errorDescription: String? {
        switch self {
        case .unimplemented:
            return "This command has not been implemented"
        }
    }
}
