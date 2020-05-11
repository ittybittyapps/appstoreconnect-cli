// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBuildsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list builds for all apps in App Store Connect.")

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by app bundle identifier. eg. com.example.App",
            valueName: "bundle-id"
        )
    )
    var filterBundleIds: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by whether the build has expired (true or false)",
            valueName: "expired"
        )
    )
    var filterExpired: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by the pre-release version number of a build",
            valueName: "pre-release-version"
        )
    )
    var filterPreReleaseVersions: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by the build number of a build",
            valueName: "build-number"
        )
    )
    var filterBuildNumbers:[String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by the processing state a build \(ListBuilds.Filter.ProcessingState.allCases)",
            valueName: "processing-state"
     )
    )
    var filterProcessingStates: [ListBuilds.Filter.ProcessingState]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by the beta review state of a build",
            valueName: "beta-review-state"
        )
    )
    var filterBetaReviewStates: [String]

    @Option(help: "Limit the number of individualTesters & betaBuildLocalizations")
    var limit: Int?
    
    func run() throws {
        let service = try makeService()

        let result = try service.listBuilds(
            filterBundleIds: filterBundleIds,
            filterExpired: filterExpired,
            filterPreReleaseVersions: filterPreReleaseVersions,
            filterBuildNumbers: filterBuildNumbers,
            filterProcessingStates: filterProcessingStates,
            filterBetaReviewStates: filterBetaReviewStates,
            limit: limit
        )

        result.0.render(format: common.outputFormat)

        try pagingSupport(links: result.1, fetcher: service.listBuilds)
    }
}
