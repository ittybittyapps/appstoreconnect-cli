// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct ReadBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Read a beta group"
    )

    @OptionGroup()
    var common: CommonOptions

    func run() throws {
        let service = try makeService()
    }
}
