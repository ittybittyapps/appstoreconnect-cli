// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation
import struct Model.BundleId

struct ListBundleIdsCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list bundle IDs that are registered to your team."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of resources (maximum 200).")
    var limit: Int?

    @OptionGroup()
    var filters: FilterOptions

    func run() throws {
        let service = try makeService()

        let request = APIEndpoint.listBundleIds(
            filter: [BundleIds.Filter](filters),
            limit: limit
        )

        let bundleId = try service.request(request)
            .map { $0.data.map(BundleId.init) }
            .await()

        bundleId.render(format: common.outputFormat)
    }
}

extension ListBundleIdsCommand {
    struct FilterOptions: ParsableArguments {
        @Option(parsing: .upToNextOption, help: "Filter the results by reverse-DNS bundle ID identifier (eg. com.example.app)")
        var filterIdentifier: [String]

        @Option(parsing: .upToNextOption, help: "Filter the results by app name")
        var filterName: [String]

        @Option(
            parsing: .upToNextOption,
            help: "Filter the results by platform (\(Platform.allCases.description))."
        )
        var filterPlatform: [Platform]

        @Option(parsing: .upToNextOption, help: "Filter the results by seed ID")
        var filterSeedId: [String]
    }
}

extension Array where Element == BundleIds.Filter {
    init?(_ options: ListBundleIdsCommand.FilterOptions) {
        var filters = [Element]()

        if options.filterIdentifier.isEmpty == false {
            filters.append(.identifier(options.filterIdentifier))
        }

        if options.filterName.isEmpty == false {
            filters.append(.name(options.filterName))
        }

        if options.filterPlatform.isEmpty == false {
            filters.append(.platform(options.filterPlatform))
        }

        if options.filterSeedId.isEmpty == false {
            filters.append(.seedId(options.filterSeedId))
        }

        self.init(filters)
    }
}
