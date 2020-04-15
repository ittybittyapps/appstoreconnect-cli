// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension BundleIdPlatform: CaseIterable, ExpressibleByArgument, CustomStringConvertible {
    public typealias AllCases = [BundleIdPlatform]
    public static var allCases: AllCases {
        [.iOS, .macOS, .universal]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
