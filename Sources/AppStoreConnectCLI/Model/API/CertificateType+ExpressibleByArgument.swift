// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

extension CertificateType: CaseIterable, ExpressibleByArgument, CustomStringConvertible {
    public typealias AllCases = [CertificateType]
    public static var allCases: AllCases {
        [
            .iOSDevelopment,
            .iOSDistribution,
            .macAppDistribution,
            .macInstallerDistribution,
            .macAppDevelopment,
            .developerIdKext,
            .developerIdApplication,
        ]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
