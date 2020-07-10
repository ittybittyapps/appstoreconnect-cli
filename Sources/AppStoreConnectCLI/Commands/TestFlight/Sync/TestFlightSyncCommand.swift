// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct TestFlightSyncCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sync",
        abstract: "Sync information about testflight with provided configuration file.",
        subcommands: [
            TestFlightPullCommand.self,
            TestFlightPushCommand.self
        ]
    )
}
