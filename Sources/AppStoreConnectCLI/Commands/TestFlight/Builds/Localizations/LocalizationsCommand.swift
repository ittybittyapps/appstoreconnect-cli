// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct LocalizationsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "localization",
        abstract: "Beta test information about builds, specific to a locale.",
        subcommands: [
            ListLocalizationsCommand.self,
            ReadLocalizationCommand.self,
        ],
        defaultSubcommand: ListLocalizationsCommand.self
    )
    public init() { }
}
