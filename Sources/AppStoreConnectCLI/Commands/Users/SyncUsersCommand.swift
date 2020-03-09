// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct SyncUsersCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "sync",
        abstract: "Sync information about a users on your team with provided configuration file.")

    @Argument(help: "The path to configuration file.")
    var config: String

    @Option(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        // TODO
        print(self.dryRun as Any)
    }
}

