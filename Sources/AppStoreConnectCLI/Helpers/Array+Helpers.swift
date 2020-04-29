// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

extension Array where Element == String {
    func isSubarray(of array: [String]) -> Bool {
        Set(self).isSubset(of: Set(array))
    }
}
