// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

public struct ListUsersCommand: ParsableCommand, HTTPClientBuilder, UserOutputBuilder {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of the users on your team.")

    public init() {}

    @Option(default: "../config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Option(help: "Limit the number of users to return (maximum 200).")
    var limit: Int?

    @Option(
        parsing: SingleValueParsingStrategy.unconditional,
        help: "Sort the results using the provided key (\(ListUsers.Sort.allCases.map { $0.rawValue }.joined(separator: ", "))).\nThe `-` prefix indicates descending order."
    )
    var sort: ListUsers.Sort?

    @Option(
        help: "Filter the results by the specified username.",
        transform: { $0.lowercased() }
    )
    var filterUsername: [String?]

    @Option(
        parsing: ArrayParsingStrategy.singleValue,
        help: ArgumentHelp(stringLiteral: "Filter the results by the specified roles (\(UserRole.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    )
    var filterRole: [UserRole?]

    @Option(
        parsing: ArrayParsingStrategy.singleValue,
        help: ArgumentHelp(stringLiteral: "Filter the results by the app(s) visible to each user.\nUsers with access to all apps will always be included."),
        transform: { $0.lowercased() }
    )
    var filterVisibleApps: [String?]

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    public func run() throws {
        let api = try setupAPI(auth: auth)

        var filters = [ListUsers.Filter]()

        if !filterRole.isEmpty {
            filters.append(ListUsers.Filter.roles(filterRole.compactMap { $0?.rawValue }))
        }

        if !filterUsername.isEmpty {
            filters.append(ListUsers.Filter.username(filterUsername.compactMap { $0 }))
        }

        if !filterVisibleApps.isEmpty {
            filters.append(ListUsers.Filter.visibleApps(filterVisibleApps.compactMap { $0 }))
        }

        let request = APIEndpoint.users(fields: nil,
                                        include: includeVisibleApps
                                            ? [ListUsers.Include.visibleApps]
                                            : nil,
                                        limit: nil, // Limit of visibleApps if included, not limit of users
                                        sort: [sort].compactMap { $0 },
                                        filter: filters,
                                        next: nil)

        let _ = api.request(request)
            .map { $0.data.compactMap(User.fromAPIUser) }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print(String(describing: error))
                }
            }, receiveValue: { [output, includeVisibleApps] users in
                output(users, includeVisibleApps)
            })
    }
}
