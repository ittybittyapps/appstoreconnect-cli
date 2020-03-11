// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension BundleIdPlatform: CaseIterable, ExpressibleByArgument {
    public typealias AllCases = [BundleIdPlatform]
    public static var allCases: BundleIdPlatform.AllCases {
        return [.iOS, .macOS]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }
}
