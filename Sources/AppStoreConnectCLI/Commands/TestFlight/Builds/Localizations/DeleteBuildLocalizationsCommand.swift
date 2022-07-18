// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct DeleteBuildLocalizationsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a specific beta build localization associated with a build."
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    @Argument(help: "The locale information of the build localization resource. eg. (en-AU)")
    var locale: String

    func run() async throws {
        let service = try makeService()

        try await service.deleteBuildLocalization(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            locale: locale
        )
    }
}
