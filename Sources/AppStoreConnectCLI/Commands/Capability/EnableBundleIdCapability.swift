// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser

struct EnableBundleIdCapabilityCommand: CommonParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "enable",
        abstract: "Enable a capability for a bundle ID."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier to delete. Must be unique. (eg. com.example.app)")
    var bundleId: String

    @Argument(help: "Bundle Id capability type. \n \(CapabilityType.allCases)")
    var capabilityType: CapabilityType

    // TODO: CapabilitySetting

    func run() throws {
        let service = try makeService()

        try service.enableBundleIdCapability(
            bundleId: bundleId, capabilityType: capabilityType
        )
    }
}
