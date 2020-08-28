// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct ReadBuildLocalizationCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get a specific beta build localization resource."
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    @Argument(help: "The locale information of the build localization resource. eg. (en-AU)")
    var locale: String

    func run() throws {
        let service = try makeService()

        let buildLocalization = try service.readBuildLocaization(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            locale: locale
        )

        [buildLocalization].render(format: common.outputFormat)
    }
}
