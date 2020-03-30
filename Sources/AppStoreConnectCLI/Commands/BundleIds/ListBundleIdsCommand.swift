// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListBundleIdsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list bundle IDs that are registered to your team."
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Option(help: "Limit the number of resources (maximum 200).")
    var limit: Int?

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified bundle IDs")
    var filterIdentifier: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified app names")
    var filterName: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(stringLiteral: "Filter the results by the specified platform (\(Platform.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    )
    var filterPlatform: [Platform]

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified seed IDs")
    var filterSeedId: [String]

    private var filters: [BundleIds.Filter]? {
        var filters = [BundleIds.Filter]()

        if filterIdentifier.isEmpty == false {
            filters += [BundleIds.Filter.identifier(filterIdentifier)]
        }

        if filterName.isEmpty == false {
            filters += [BundleIds.Filter.name(filterName)]
        }

        if filterPlatform.isEmpty == false {
            filters += [BundleIds.Filter.platform(filterPlatform)]
        }

        if filterSeedId.isEmpty == false {
            filters += [BundleIds.Filter.seedId(filterSeedId)]
        }

        return filters
    }

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        let request = APIEndpoint.listBundleIds(
            filter: filters,
            limit: limit
        )

        _ = api.request(request)
            .map { $0.data.map(BundleId.init) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
