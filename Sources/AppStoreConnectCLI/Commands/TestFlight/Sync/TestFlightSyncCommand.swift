// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct TestFlightSyncCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sync",
        abstract: "Synchronize with Testflight via configuration files.",
        subcommands: [
            TestFlightPullCommand.self,
        ]
    )
}
