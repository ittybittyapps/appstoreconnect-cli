// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"

        return formatter.string(from: self)
    }
}
