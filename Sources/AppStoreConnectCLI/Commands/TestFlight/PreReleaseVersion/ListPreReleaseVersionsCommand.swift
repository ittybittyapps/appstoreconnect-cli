// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListPreReleaseVersionsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of prerelease versions for all apps.")

    struct Options: ParsableArguments {
        @Option(
            parsing: .upToNextOption,
            help: ArgumentHelp(
                "Filter by app bundle identifier. eg. com.example.App",
                discussion: "This option is mutually exclusive with --filter-app-id.",
                valueName: "bundle-id"
            )
        )
        var filterBundleId: [String]

        @Option(
            parsing: .upToNextOption,
            help: ArgumentHelp(
                "Filter by app AppStore ID. eg. 432156789",
                discussion: "This option is mutually exclusive with --filter-bundle-id.",
                valueName: "app-id"
            )
        )
        var filterAppId: [String]

        @Option(
            parsing: .upToNextOption,
            help: ArgumentHelp(
                "Filter by platform \(Platform.allCases)",
                valueName: "platform"
            )
        )
        var filterPlatform: [Platform]

        @Option(
            parsing: .upToNextOption,
            help: ArgumentHelp(
                "Filter by version number. eg. 1.0.1",
                valueName: "version"
            )
        )
        var filterVersion: [String]

        @Option(
            parsing: .unconditional,
            help: ArgumentHelp(
                "Sort the results using the provided key \(ListPrereleaseVersions.Sort.allCases).",
                discussion: "The `-` prefix indicates descending order."
            )
        )
        var sort: ListPrereleaseVersions.Sort?
    }

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var options: Options

    func validate() throws {
        if options.filterAppId.isEmpty == false && options.filterBundleId.isEmpty == false {
            throw ValidationError("Filtering by both Bundle ID and App ID is not supported!")
        }
    }

    func run() throws {
        try makeService()
            .listPreReleaseVersions(with: .init(options))
            .await()
            .render(format: common.outputFormat)
    }
}

private extension ListPreReleaseVersionsOperation.Options {
    init(_ options: ListPreReleaseVersionsCommand.Options) {
        self.init(
            filterAppId: options.filterAppId,
            filterBundleId: options.filterBundleId,
            filterVersion: options.filterVersion,
            filterPlatform: options.filterPlatform,            
            sort: options.sort
        )
    }
}

