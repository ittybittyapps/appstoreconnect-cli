// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation
import SwiftyTextTable
import Yams

struct ListAppsCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list apps added in App Store Connect"
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Option(help: "Limit the number of resources (maximum 200).")
    var limit: Int?

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    @Option(help: "Filter the results by the specified bundle IDs; comma-separated for multiple values")
    var filterBundleIds: [String]

    @Option(help: "Filter the results by the specified app names; comma-separated for multiple values")
    var filterNames: [String]

    @Option(help: "Filter the results by the specified app SKUs; comma-separated for multiple values")
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
        let api = try HTTPClient(authenticationYmlPath: auth)

        let limits = limit.map { [ListApps.Limit.apps($0)] }

        let request = APIEndpoint.apps(
            filters: listFilters,
            limits: limits
        )

        _ = api.request(request)
            .map { $0.data.map(App.init) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
