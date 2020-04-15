// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension Platform: CaseIterable, ExpressibleByArgument, CustomStringConvertible {
    public typealias AllCases = [Platform]

    public static var allCases: AllCases {
        [ios, macOs, tvOs, watchOs]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
