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
        help: "Filter the results by app ids, these supercede bundle ids"
    ) var filterAppIds: [String]

    @Option(
        parsing: .upToNextOption,
        help: "Filter the results by bundle ids, these are superceded by app ids"
    ) var filterBundleIds: [String]

    func run() throws {
        let service = try makeService()

        let betaGroups = try service.listBetaGroups(
            appIds: filterAppIds,
            bundleIds: filterBundleIds
        )

        betaGroups.render(format: common.outputFormat)
    }
}
