// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension ListPrereleaseVersions.Filter.BuildsProcessingState: Codable, ExpressibleByArgument, CustomStringConvertible {

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
