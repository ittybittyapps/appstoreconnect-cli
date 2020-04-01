// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct TestFlightBuildsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "builds",
        abstract: "Information about app builds.",
        subcommands: [
             ListBuildsCommand.self,
            // GetBuildInfoCommand.self,
            // ModifyBuildCommand.self,
            // More...
        ])

    public init() {
    }
}
