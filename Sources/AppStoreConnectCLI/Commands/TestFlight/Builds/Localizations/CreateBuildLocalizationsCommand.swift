// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem

struct CreateBuildLocalizationsCommand: CommonParsableCommand, CreateUpdateBuildLocalizationCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create localized What’s New text for a build."
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

        let buildLocalization = try service.createBuildLocalization(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            locale: localization.locale,
            whatsNew: whatsNew
        )

        // Render long text by SwiftyTable is not supported yet
        [buildLocalization].render(format: common.outputFormat == .table ? .json : common.outputFormat)
    }
}
