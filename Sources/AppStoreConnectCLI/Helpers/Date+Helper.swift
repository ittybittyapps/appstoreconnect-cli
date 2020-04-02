// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension Date {
    var formattedDate: String {
        ISO8601DateFormatter().string(from: self)
    }
}
