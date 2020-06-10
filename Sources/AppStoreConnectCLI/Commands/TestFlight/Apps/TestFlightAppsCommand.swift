// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct TestFlightAppsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "apps",
        abstract: "Application commands",
        subcommands: [
            ListAppsCommand.self,
            ReadAppCommand.self,
            // GetAppInfoCommand.self,
            // More...
        ],
        defaultSubcommand: ListAppsCommand.self
    )
}
