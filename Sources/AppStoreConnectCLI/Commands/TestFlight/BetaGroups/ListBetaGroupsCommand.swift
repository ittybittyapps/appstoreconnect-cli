// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK

struct ListBetaGroupsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List beta groups"
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var appLookupOptions: AppLookupOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by beta group name",
            discussion: """
            This filter works on partial matches in a case insensitive fashion, \
            e.g. 'group' will match 'myGroup'
            """,
            valueName: "filter-names"
        )
    )
    var filterNames: [String] = []

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(ListBetaGroups.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: ListBetaGroups.Sort?

    @Flag(
        help: "Exclude apple store connect internal beta groups."
    )
    var excludeInternal = false

    func run() throws {
        let service = try makeService()

        let betaGroups = try service.listBetaGroups(
            filterIdentifiers: appLookupOptions.filterIdentifiers,
            names: filterNames,
            sort: sort,
            excludeInternal: excludeInternal
        )

        betaGroups.render(options: common.outputOptions)
    }
}
