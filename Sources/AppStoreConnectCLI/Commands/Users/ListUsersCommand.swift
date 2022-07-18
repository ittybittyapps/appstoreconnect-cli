// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import Model

public struct ListUsersCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of the users on your team.")

    public init() {}

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number visible apps to return (maximum 50).")
    var limitVisibleApps: Int?

    @Option(help: "Limit the number of users to return (maximum 200).")
    var limitUsers: Int?

    @Option(
        parsing: SingleValueParsingStrategy.unconditional,
        help: "Sort the results using the provided key (\(Sort.allCases.map { $0.rawValue }.joined(separator: ", "))).\nThe `-` prefix indicates descending order."
    )
    var sort: Sort?

    @Option(
        parsing: .upToNextOption,
        help: "Filter the results by the specified username.",
        transform: { $0.lowercased() }
    )
    var filterUsername: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(stringLiteral: "Filter the results by the specified roles (\(UserRole.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    )
    var filterRole: [UserRole] = []

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(discussion:
            """
            Filter the results by the app(s) resources ids or bundle ids visible to each user.
            Users with access to all apps will always be included.
            """
        ),
        transform: AppLookupIdentifier.init
    )
    var filterVisibleApps: [AppLookupIdentifier] = []

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps = false

    public enum Sort: String, CaseIterable, ExpressibleByArgument {
        case lastNameAscending = "lastName"
        case lastNameDescending = "-lastName"
        case usernameAscending = "username"
        case usernameDescending = "-username"
    }
    
    public func run() async throws {
        let service = try makeService()

        let users = try await service
            .listUsers(
                limitVisibleApps: limitVisibleApps,
                limitUsers: limitUsers,
                sort: sort?.rawValue,
                filterUsername: filterUsername,
                filterRole: filterRole,
                filterVisibleApps: filterVisibleApps,
                includeVisibleApps: includeVisibleApps
            )

        users.render(options: common.outputOptions)
    }
}
