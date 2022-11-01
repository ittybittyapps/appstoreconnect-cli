// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import ArgumentParser
import Foundation

extension CapabilityType: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }
}
