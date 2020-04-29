// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension ProfileState: CaseIterable, ExpressibleByArgument, CustomStringConvertible {
    public typealias AllCases = [ProfileState]
    public static var allCases: AllCases {
        [.active, .invalid]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
