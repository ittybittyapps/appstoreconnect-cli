// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListAppsCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list apps added in App Store Connect"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of resources (maximum 200).")
    var limit: Int?

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified bundle IDs")
    var filterBundleIds: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified app names")
    var filterNames: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified app SKUs")
    var filterSkus: [String]

    private var listFilters: [ListApps.Filter]? {
        var filters = [ListApps.Filter]()

        if filterBundleIds.isEmpty == false {
            filters += [ListApps.Filter.bundleId(filterBundleIds)]
        }

        if filterNames.isEmpty == false {
            filters += [ListApps.Filter.name(filterNames)]
        }

        if filterSkus.isEmpty == false {
            filters += [ListApps.Filter.sku(filterSkus)]
        }

        return filters
    }

    func run() throws {
        let api = try makeService()

        let limits = limit.map { [ListApps.Limit.apps($0)] }

        let request = APIEndpoint.apps(
            filters: listFilters,
            limits: limits
        )

        _ = api.request(request)
            .map { $0.data.map(App.init) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
