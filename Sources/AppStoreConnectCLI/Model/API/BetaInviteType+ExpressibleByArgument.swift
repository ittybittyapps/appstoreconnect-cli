// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK

extension BetaInviteType: CustomStringConvertible, ExpressibleByArgument {
    public typealias AllCases = [BetaInviteType]
    public static var allCases: AllCases {
        [.email, .publicLink]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
