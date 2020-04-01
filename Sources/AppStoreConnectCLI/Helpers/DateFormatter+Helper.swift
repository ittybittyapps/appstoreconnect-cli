// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension DateFormatter {
    func formatDateToString(_ date: Date?) -> String {
        self.dateFormat = "dd/MM/yyyy HH:mm:ss"

        return date != nil ? string(from: date!) : ""
    }
}
