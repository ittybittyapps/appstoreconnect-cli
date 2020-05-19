// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct TestFlightPreReleaseVersionCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "prereleaseversion",
        abstract: "PreRelease version commands.",
        subcommands: [
            ListPreReleaseVersionsCommand.self,
            ReadPreReleaseVersionCommand.self
        ],
        defaultSubcommand: ListPreReleaseVersionsCommand.self)

    public init() {
    }
}
