// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

extension CapabilityType: CaseIterable, ExpressibleByArgument, CustomStringConvertible {
    public typealias AllCases = [CapabilityType]

    public static var allCases: AllCases {
        [
            .icloud,
            .inAppPurchase,
            .gameCenter,
            .pushNotifications,
            .wallet,
            .interAppAudio,
            .maps,
            .associatedDomains,
            .personalVpn,
            .appGroups,
            .healthkit,
            .homekit,
            .wirelessAccessoryConfiguration,
            .applePay,
            .dataProtection,
            .sirikit,
            .networkExtensions,
            .multipath,
            .hotSpot,
            .nfcTagReading,
            .classkit,
            .autofillCredentialProvider,
            .accessWifiInformation
        ]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
