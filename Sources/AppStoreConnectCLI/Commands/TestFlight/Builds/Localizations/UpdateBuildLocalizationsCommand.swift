// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem

struct UpdateBuildLocalizationsCommand: CommonParsableCommand, CreateUpdateBuildLocalizationCommand {
    static var configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update the localized What’s New text for a specific beta build and locale.",
        discussion: """
        Text from `stdin` will be read when a file path or what's new isn't specified.
        """
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    @OptionGroup()
    var localization: BuildLocalizationInputArguments

    func validate() throws {
        try validateWhatsNewInput()
    }

    func run() throws {
        let service = try makeService()

        let buildLocalization = try service.updateBuildLocalization(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            locale: localization.locale,
            whatsNew: readWhatsNew()
        )

        [buildLocalization].render(options: common.outputOptions)
    }
}
