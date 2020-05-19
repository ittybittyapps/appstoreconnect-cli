// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListPreReleaseVersionsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of prerelease versions for all apps.")

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by app bundle identifier. eg. com.example.App",
            discussion: "This option is mutually exclusive with --filter-app-id.",
            valueName: "bundle-id"
        )
    )
    var filterBundleIds: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by app AppStore ID. eg. 432156789",
            discussion: "This option is mutually exclusive with --filter-bundle-id.",
            valueName: "app-id"
        )
    )
    var filterAppIds: [String]

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

        let prereleaseVersions = filterAppIds.isEmpty
            ? try service.listPreReleaseVersions(filterBundleIds: filterBundleIds, filterVersions: filterVersions, filterPlatforms: filterPlatforms, sort: sort)
            : try service.listPreReleaseVersions(filterAppIds: filterAppIds, filterVersions: filterVersions, filterPlatforms: filterPlatforms, sort: sort)

        prereleaseVersions.render(format: common.outputFormat)
    }
}

