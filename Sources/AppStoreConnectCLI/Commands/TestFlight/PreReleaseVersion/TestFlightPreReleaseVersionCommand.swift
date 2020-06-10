// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct TestFlightPreReleaseVersionCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "prereleaseversion",
        abstract: "Platform-specific versions of your app intended for distribution to beta testers.",
        subcommands: [
            ListPreReleaseVersionsCommand.self,
            ReadPreReleaseVersionCommand.self,
        ],
        defaultSubcommand: ListPreReleaseVersionsCommand.self)

    public init() {
    }
}
