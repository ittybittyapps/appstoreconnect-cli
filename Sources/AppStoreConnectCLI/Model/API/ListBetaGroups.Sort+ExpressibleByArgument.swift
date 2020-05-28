// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ListBetaGroups.Sort: CustomStringConvertible, ExpressibleByArgument {
    public var description: String {
        rawValue
    }
}
