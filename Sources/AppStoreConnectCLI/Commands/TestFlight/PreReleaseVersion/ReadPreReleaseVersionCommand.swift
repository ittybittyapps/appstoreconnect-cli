// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct ReadPreReleaseVersionCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information about a specific prerelease version.")

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var appLookupArgument: AppLookupArgument

    @Argument(
        help: ArgumentHelp(
            "The version number of the prerelease version of your app.",
            discussion: "Please input a specific version no"
        )
    )
    var version: String

    func run() throws {
        let service = try makeService()

        let prereleaseVersion = try service.readPreReleaseVersion(filterIdentifier: appLookupArgument.identifier, filterVersion: version)
        prereleaseVersion.render(options: common.outputOptions)
    }
}
