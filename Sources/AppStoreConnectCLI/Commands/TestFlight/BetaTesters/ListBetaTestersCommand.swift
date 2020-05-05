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

    @Option(help: "Beta tester's email.")
    var filterEmail: String?

    @Option(help: "Beta tester's first name.")
    var filterFirstName: String?

    @Option(help: "Beta tester's last name.")
    var filterLastName: String?

    @Option(
        help: """
        An invite type that indicates if a beta tester was invited by an email invite or used a TestFlight public link to join a beta test. \n
        Possible values \(BetaInviteType.allCases).
        """
    ) var filterInviteType: BetaInviteType?

    @Option(
        parsing: .upToNextOption,
        help: "Application Bundle Ids. (eg. com.example.app)"
    ) var filterApps: [String]

    @Option(
        parsing: .upToNextOption,
        help: "TestFlight beta group names."
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
        if !filterApps.isEmpty && !filterGroupNames.isEmpty {
            throw ValidationError("Only one of these relationship filters ('filterApps', 'filterGroupNames') can be applied.")
        }
    }

    func run() throws {
        let service = try makeService()

        let betaTesters = try service.listBetaTesters(
            email: filterEmail,
            firstName: filterFirstName,
            lastName: filterLastName,
            inviteType: filterInviteType,
            apps: filterApps,
            groupNames: filterGroupNames,
            sort: sort,
            limit: limit,
            relatedResourcesLimit: relatedResourcesLimit
        )

        betaTesters.render(format: common.outputFormat)
    }
}
