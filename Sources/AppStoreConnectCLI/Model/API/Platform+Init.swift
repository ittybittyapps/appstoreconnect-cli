// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension Platform: CaseIterable, ExpressibleByArgument {
    public typealias AllCases = [Platform]
    public static var allCases: Platform.AllCases {
        return [ios, macOs, tvOs, watchOs]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }
}
