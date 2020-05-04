// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct ModifyBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Modify a beta group"
    )

    @OptionGroup()
    var common: CommonOptions

    func run() throws {
    }
}
