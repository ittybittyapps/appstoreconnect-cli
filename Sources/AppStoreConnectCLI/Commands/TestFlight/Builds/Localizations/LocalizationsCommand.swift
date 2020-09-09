// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct LocalizationsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "localization",
        abstract: "Beta test information about builds, specific to a locale.",
        subcommands: [
            CreateBuildLocalizationsCommand.self,
            DeleteBuildLocalizationsCommand.self,
            ListBuildLocalizationsCommand.self,
            ReadBuildLocalizationCommand.self,
            UpdateBuildLocalizationsCommand.self,
        ],
        defaultSubcommand: ListBuildLocalizationsCommand.self
    )
    public init() { }
}
