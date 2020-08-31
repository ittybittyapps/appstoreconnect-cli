// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem
import Model

struct TestFlightPullCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "pull",
        abstract: "Pull TestFlight configuration, overwriting local configuration files."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: "Filter by only including apps with the specified bundleIds in the configuration"
    ) var filterBundleIds: [String]

    @Option(
        default: "./config/apps",
        help: "Path to output/write the TestFlight configuration."
    ) var outputPath: String

    func run() throws {
        let service = try makeService()

        // TODO: A new service function should be created to efficiently gather these models
        let apps = try service.listApps(bundleIds: filterBundleIds)
        let identifiers = apps.map { app in AppLookupIdentifier.appId(app.id) }
        let testers = try service.listBetaTesters(filterIdentifiers: identifiers)
        let groups = try service.listBetaGroups(filterIdentifiers: identifiers)

        let processor = TestflightConfigurationProcessor(appsFolderPath: outputPath)
        try processor.writeConfiguration(apps: apps, testers: testers, groups: groups)

        // TODO: Remove when the pull is completed
        throw CommandError.unimplemented
    }

}
