// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser

struct ListPreReleaseVersionsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of prerelease versions for all apps.")

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var appLookupOptions: AppLookupOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by platform \(Platform.allCases)",
            valueName: "platform"
        )
    )
    var filterPlatforms: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by version number. eg. 1.0.1",
            valueName: "version"
        )
    )
    var filterVersions: [String]

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(ListPrereleaseVersions.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: ListPrereleaseVersions.Sort?

    func run() throws {
        let service = try makeService()

        let prereleaseVersions = try service.listPreReleaseVersions(
            filterIdentifiers: appLookupOptions.filterIdentifiers,
            filterVersions: filterVersions,
            filterPlatforms: filterPlatforms,
            sort: sort
        )

        prereleaseVersions.render(options: common.outputOptions)
    }
}
