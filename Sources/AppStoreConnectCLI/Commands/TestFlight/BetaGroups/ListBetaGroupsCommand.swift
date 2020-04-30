// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct ListBetaGroupsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List beta groups"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by app AppStore ID. eg. 432156789",
            discussion: "This option is mutually exclusive with --filter-bundle-ids.",
            valueName: "app-id"
        )
    ) var filterAppIds: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by app bundle identifier. eg. com.example.App",
            discussion: "This option is mutually exclusive with --filter-app-ids.",
            valueName: "bundle-id"
        )
    ) var filterBundleIds: [String]

    func validate() throws {
        if filterAppIds.isEmpty == false && filterBundleIds.isEmpty == false {
            throw ValidationError("Filtering by both Bundle ID and App ID is not supported!")
        }
    }

    func run() throws {
        let service = try makeService()

        let betaGroups = filterBundleIds.isEmpty
            ? try service.listBetaGroups(appIds: filterAppIds)
            : try service.listBetaGroups(bundleIds: filterBundleIds)

        betaGroups.render(format: common.outputFormat)
    }
}
