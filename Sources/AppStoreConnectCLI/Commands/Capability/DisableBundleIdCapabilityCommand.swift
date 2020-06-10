// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser

struct DisableBundleIdCapabilityCommand: CommonParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "disable",
        abstract: "Disable a capability for a bundle ID."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier to delete. Must be unique. (eg. com.example.app)")
    var bundleId: String

    @Argument(help: ArgumentHelp("Bundle Id capability type.", discussion: "One of \(CapabilityType.allCases)"))
    var capabilityType: CapabilityType

    func run() throws {
        let service = try makeService()

        try service.disableBundleIdCapability(bundleId: bundleId, capabilityType: capabilityType)
    }
}
