// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK

enum BundleIdCapability: String, Decodable {
    case icloud
    case inAppPurchase
    case gameCenter
    case pushNotifications
    case wallet
    case interAppAudio
    case maps
    case associatedDomains
    case personalVpn
    case appGroups
    case healthkit
    case homekit
    case wirelessAccessoryConfiguration
    case applePay
    case dataProtection
    case sirikit
    case networkExtensions
    case multipath
    case hotSpot
    case nfcTagReading
    case classkit
    case autofillCredentialProvider
    case accessWifiInformation
}

struct BundleId: Decodable {
    var identifier: String
    var name: String
    var platform: BundleIdPlatform
    var seedId: String
    var capabilities: [BundleIdCapability]?
}
