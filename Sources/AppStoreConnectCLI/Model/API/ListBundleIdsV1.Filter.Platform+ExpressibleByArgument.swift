// Copyright 2022 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Bagbutik
import Foundation

extension ListBundleIdsV1.Filter.Platform: Codable, ExpressibleByArgument {

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

}
