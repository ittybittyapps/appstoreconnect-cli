// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

extension DeviceStatus: CaseIterable, ExpressibleByArgument {
    public typealias AllCases = [DeviceStatus]
    public static var allCases: DeviceStatus.AllCases {
        return [.enabled, .disabled]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }
}
