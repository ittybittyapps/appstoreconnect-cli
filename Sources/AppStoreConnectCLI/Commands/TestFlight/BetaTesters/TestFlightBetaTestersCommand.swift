// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct TestFlightBetaTestersCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "betatesters",
        abstract: "People who can install and test prerelease builds.",
        subcommands: [
            InviteBetaTesterCommand.self,
            DeleteBetaTesterCommand.self,
            ListBetaTestersCommand.self,
            ListBetaTesterByBuildsCommand.self,
            ListBetaTesterByGroupCommand.self,
            ReadBetaTesterCommand.self,
            RemoveTesterFromGroupsCommand.self,
            AddTesterToGroupsCommand.self,
        ],
        defaultSubcommand: ListBetaTestersCommand.self
    )

    public init() {
    }
}
