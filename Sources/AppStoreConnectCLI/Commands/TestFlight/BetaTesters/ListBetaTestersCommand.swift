// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

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
        if !filterAppIds.isEmpty && !filterBundleIds.isEmpty {
            throw ValidationError("Filtering by both Bundle ID and App ID is not supported!")
        }

        if (!filterAppIds.isEmpty || !filterBundleIds.isEmpty) && !filterGroupNames.isEmpty {
            throw ValidationError("Only one of these relationship filters ('app-id, bundle-id', 'group-name') can be applied.")
        }
    }

    func run() throws {
        let service = try makeService()

        let betaTesters = try service.listBetaTesters(
            email: filterEmail,
            firstName: filterFirstName,
            lastName: filterLastName,
            inviteType: filterInviteType,
            appIds: filterAppIds,
            bundleIds: filterBundleIds,
            groupNames: filterGroupNames,
            sort: sort,
            limit: limit,
            relatedResourcesLimit: relatedResourcesLimit
        )

        betaTesters.render(format: common.outputFormat)
    }
}
