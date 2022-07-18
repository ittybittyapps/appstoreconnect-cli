// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation
import struct Model.App

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
    var filterBundleIds: [String] = []

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified app names")
    var filterNames: [String] = []

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified app SKUs")
    var filterSkus: [String] = []

    func run() async throws {
        let service = try makeService()

        let apps = try await service.listApps(
            bundleIds: filterBundleIds,
            names: filterNames,
            skus: filterSkus,
            limit: limit
        )

        apps.render(options: common.outputOptions)
    }
}
