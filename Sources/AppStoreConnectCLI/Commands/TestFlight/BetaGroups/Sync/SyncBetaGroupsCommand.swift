// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct SyncBetaGroupsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sync",
        abstract: "Sync information about beta groups with provided configuration file.",
        subcommands: [
            PullBetaGroupsCommand.self,
            PushBetaGroupsCommand.self,
        ]
    )
}
