// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct CreateBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new beta group"
    )

    @OptionGroup()
    var common: CommonOptions
}
