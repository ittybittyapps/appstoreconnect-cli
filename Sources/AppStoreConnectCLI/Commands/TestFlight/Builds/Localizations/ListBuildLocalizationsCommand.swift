// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct ListBuildLocalizationsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list beta build localization resources."
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    @Option(help: "Limit the number of resources to return.")
    var limit: Int?

    func run() async throws {
        let service = try makeService()

        let localizations = try await service.listBuildsLocalizations(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            limit: limit
        )

        localizations.render(options: common.outputOptions)
    }
}
