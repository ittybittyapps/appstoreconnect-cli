// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Model

struct ListBundleIdsCommand: CommonParsableCommand {
    typealias Platform = ListBundleIdsOperation.Options.Platform
    
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list bundle IDs that are registered to your team."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        help: "Limit the number of resources (maximum 200).",
        transform: { Int($0).map { min($0, 200) } }
    )
    var limit: Int?

    @Option(parsing: .upToNextOption, help: "Filter the results by reverse-DNS bundle ID identifier (eg. com.example.app)")
    var filterIdentifier: [String] = []

    @Option(parsing: .upToNextOption, help: "Filter the results by app name")
    var filterName: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp("Filter the results by platform. One of \(Platform.allValueStrings.formatted(.list(type: .or)))."),
        completion: .list(Platform.allValueStrings)
    )
    var filterPlatform: [Platform] = []

    @Option(parsing: .upToNextOption, help: "Filter the results by seed ID")
    var filterSeedId: [String] = []

    func run() async throws {
        try await ListBundleIdsOperation(
            service: .init(authOptions: common.authOptions),
            options: .init(
                identifiers: filterIdentifier,
                names: filterName,
                platforms: filterPlatform,
                seedIds: filterSeedId,
                limit: limit
            )
        )
        .execute()
        .map { Model.BundleId($0) }
        .render(options: common.outputOptions)
    }
}
