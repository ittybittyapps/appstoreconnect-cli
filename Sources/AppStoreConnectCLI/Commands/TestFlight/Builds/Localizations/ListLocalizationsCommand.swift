// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct ListLocalizationsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list beta build localizations currently associated with apps."
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    @Option(help: "Limit the number of resources to return.")
    var limit: Int?

    func run() throws {
        let service = try makeService()

        let localizations = try service.listBuildsLocalizations(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            limit: limit
        )

        localizations.render(format: common.outputFormat)
    }
}
