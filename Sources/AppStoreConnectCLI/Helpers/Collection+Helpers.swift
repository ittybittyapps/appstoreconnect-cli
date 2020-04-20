// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension Collection {
    func nilIfEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
