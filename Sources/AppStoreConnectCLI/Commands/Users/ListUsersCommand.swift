// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

public struct ListUsersCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of the users on your team.")

    public init() {}

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number visible apps to return (maximum 50).")
    var limitVisibleApps: Int?

    @Option(
        parsing: SingleValueParsingStrategy.unconditional,
        help: "Sort the results using the provided key (\(ListUsers.Sort.allCases.map { $0.rawValue }.joined(separator: ", "))).\nThe `-` prefix indicates descending order."
    )
    var sort: ListUsers.Sort?

    @Option(
        parsing: .upToNextOption,
        help: "Filter the results by the specified username.",
        transform: { $0.lowercased() }
    )
    var filterUsername: [String?]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(stringLiteral: "Filter the results by the specified roles (\(UserRole.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    )
    var filterRole: [UserRole?]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(stringLiteral: "Filter the results by the app(s) visible to each user.\nUsers with access to all apps will always be included."),
        transform: { $0.lowercased() }
    )
    var filterVisibleApps: [String?]

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

    public func run() throws {
        let api = try makeClient()

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

        let request = APIEndpoint.users(
            fields: nil,
            include: includeVisibleApps
                ? [ListUsers.Include.visibleApps]
                : nil,
            limit: limitVisibleApps.map { [ListUsers.Limit.visibleApps($0)] },
            sort: [sort].compactMap { $0 },
            filter: filters,
            next: nil)

        _ = api.request(request)
            .map(User.fromAPIResponse)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
