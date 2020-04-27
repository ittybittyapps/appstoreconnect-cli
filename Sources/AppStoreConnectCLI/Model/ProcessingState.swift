// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

enum ProcessingState: String, CaseIterable, CustomStringConvertible {
    case processing = "PROCESSING"
    case failed = "FAILED"
    case invalid = "INVALID"
    case valid = "VALID"

    public var description: String {
        rawValue.lowercased()
    }
}
