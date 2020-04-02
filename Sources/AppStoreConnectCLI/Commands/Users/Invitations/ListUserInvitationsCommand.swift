// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListUserInvitationsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list-invitations",
        abstract: "Get a list of pending invitations to join your team."
    )

    @OptionGroup()
    var authOptions: AuthOptions

    @Option(help: "Limit the number of users to return (maximum 200).")
    var limit: Int?

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified username")
    var filterEmail: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified roles")
    var filterRole: [UserRole]

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

    @Option(default: .table, help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat

    private var filters: [ListInvitedUsers.Filter]? {
        var filters = [ListInvitedUsers.Filter]()

        if filterEmail.isEmpty == false {
            filters += [ListInvitedUsers.Filter.email(filterEmail)]
        }

        if filterRole.isEmpty == false {
            filters += [ListInvitedUsers.Filter.roles(filterRole.map { $0.rawValue })]
        }

        return filters
    }

    public func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        let endpoint = APIEndpoint.invitedUsers(
            limit: limit.map { [ListInvitedUsers.Limit.visibleApps($0)] } ?? [],
            filter: filters
        )

        _ = api.request(endpoint)
            .map(\.data)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
