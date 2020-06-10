// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct CapabilityCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "capability",
        abstract: "Manage the app capabilities for a bundle ID.",
        subcommands: [
            EnableBundleIdCapabilityCommand.self,
            DisableBundleIdCapabilityCommand.self,
        ]
    )
}
