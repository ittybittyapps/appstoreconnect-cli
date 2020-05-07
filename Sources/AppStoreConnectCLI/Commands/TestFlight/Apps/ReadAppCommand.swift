// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ReadAppCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Find and read app info"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        help: ArgumentHelp(
            "Filter by app AppStore ID. eg. 432156789",
            discussion: "This option is mutually exclusive with --filter-bundle-id.",
            valueName: "app-id"
        )
    ) var filterAppId: String?

    @Option(
        help: ArgumentHelp(
            "Filter by app bundle identifier. eg. com.example.App",
            discussion: "This option is mutually exclusive with --filter-app-id.",
            valueName: "bundle-id"
        )
    ) var filterBundleId: String?

    func validate() throws {
        if filterAppId == nil && filterBundleId == nil {
            throw ValidationError("Missing expected argument '<app-id>' or '<bundle-id>'")
        }

        if filterAppId != nil && filterBundleId != nil {
            throw ValidationError("Filtering by both Bundle ID and App ID is not supported!")
        }
    }

    func run() throws {
        let service = try makeService()

        let app = filterAppId == nil ?
            try service.readApp(bundleId: filterBundleId!):
            try service.readApp(appId: filterAppId!)

        app.render(format: common.outputFormat)
    }
}
