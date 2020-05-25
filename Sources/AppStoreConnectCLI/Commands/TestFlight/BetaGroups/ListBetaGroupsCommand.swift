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

    @OptionGroup()
    var identifierOptions: IdentifierOptions

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
    ) var filterNames: [String]

    func run() throws {
        let service = try makeService()

        let betaGroups = try service.listBetaGroups(filterIdentifiers: identifierOptions.filterIdentifiers, names: filterNames)

        betaGroups.render(format: common.outputFormat)
    }
}
