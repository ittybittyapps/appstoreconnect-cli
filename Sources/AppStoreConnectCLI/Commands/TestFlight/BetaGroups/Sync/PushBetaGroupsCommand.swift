// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import struct Model.BetaGroup

struct PushBetaGroupsCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "push",
        abstract: "Push local beta group config files to server, update server beta groups"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/betagroups",
        help: "Path to the Folder containing the information about beta groups. (default: './config/betagroups')"
    ) var inputPath: String

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {

    }

}
