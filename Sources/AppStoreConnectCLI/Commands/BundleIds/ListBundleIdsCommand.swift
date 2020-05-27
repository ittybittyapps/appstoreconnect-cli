// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser

struct ListBundleIdsCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list bundle IDs that are registered to your team."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of resources (maximum 200).")
    var limit: Int?

    @Option(parsing: .upToNextOption, help: "Filter the results by reverse-DNS bundle ID identifier (eg. com.example.app)")
    var filterIdentifier: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by app name")
    var filterName: [String]

    @Option(
        parsing: .upToNextOption,
        help: "Filter the results by platform (\(Platform.allCases.description))."
    )
    var filterPlatform: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by seed ID")
    var filterSeedId: [String]

    func run() throws {
        let service = try makeService()

        let bundleIds = try service.listBundleIds(
            identifiers: filterIdentifier,
            names: filterName,
            platforms: filterPlatform,
            seedIds: filterSeedId,
            limit: limit
        )

        bundleIds.render(format: common.outputFormat)
    }
}
