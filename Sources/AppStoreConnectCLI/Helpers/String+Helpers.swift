// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension String {

    // Taken from: https://stackoverflow.com/a/45535926/20480
    public func removingCharacters(in set: CharacterSet) -> String {
        let filtered = unicodeScalars.lazy.filter { !set.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }

    func truncate(to length: Int, with trailing: String = "…") -> String {
        (self.count > length) ? self.prefix(length) + trailing : self
    }
}
