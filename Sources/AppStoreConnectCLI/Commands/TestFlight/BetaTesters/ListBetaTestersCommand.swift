// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine

struct ListBetaTestersCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List beta testers")

    @OptionGroup()
    var common: CommonOptions

    @Option(
        help: ArgumentHelp(
            "Beta tester's email.",
            valueName: "email"
        )
    ) var filterEmail: String?

    @Option(
        help: ArgumentHelp(
            "Beta tester's first name.",
            valueName: "first-name"
        )
    ) var filterFirstName: String?

    @Option(
        help: ArgumentHelp(
            "Beta tester's last name.",
            valueName: "last-name"
        )
    ) var filterLastName: String?

    @Option(
        help: ArgumentHelp(
            """
            An invite type that indicates if a beta tester was invited by an email invite or used a TestFlight public link to join a beta test. \n
            Possible values \(BetaInviteType.allCases).
            """,
            valueName: "invite-type"
        )
    ) var filterInviteType: BetaInviteType?

    @OptionGroup()
    var appLookupOptions: AppLookupOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "TestFlight beta group names.",
            valueName: "group-name"
        )
    ) var filterGroupNames: [String]

    @Option(help: "Number of resources to return. (maximum: 200)")
    var limit: Int?

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(ListBetaTesters.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    ) var sort: ListBetaTesters.Sort?

    @Option(help: "Number of included related resources to return.")
    var relatedResourcesLimit: Int?

    func validate() throws {
        if !appLookupOptions.filterIdentifiers.isEmpty && !filterGroupNames.isEmpty {
            throw ValidationError("Only one of these relationship filters ('app-id/ bundle-id', 'group-name') can be applied.")
        }
    }

    func run() throws {
        let service = try makeService()

        let betaTesters = try service.listBetaTesters(
            email: filterEmail,
            firstName: filterFirstName,
            lastName: filterLastName,
            inviteType: filterInviteType,
            filterIdentifiers: appLookupOptions.filterIdentifiers,
            groupNames: filterGroupNames,
            sort: sort,
            limit: limit,
            relatedResourcesLimit: relatedResourcesLimit
        )

        betaTesters.render(options: common.outputOptions)
    }
}
