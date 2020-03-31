// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct BundleIdsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "bundle-ids",
        abstract: "Manage the bundle IDs that uniquely identify your apps.",
        subcommands: [
            ListBundleIdsCommand.self,
            /* TODO
            ReadBundleIdCommand.self,
            ModifyBundleIdCommand.self,
            DeleteBundleIdCommand.self,
            */
            RegisterBundleIdCommand.self,
        ],
        defaultSubcommand: ListBundleIdsCommand.self
    )
}
