// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListUserInvitationsCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list-invitations",
        abstract: "Get a list of pending invitations to join your team."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number visible apps to return (maximum 50).")
    var limitVisibleApps: Int?

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified username")
    var filterEmail: [String]

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified roles")
    var filterRole: [UserRole]

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

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
        let service = try makeService()

        let endpoint = APIEndpoint.invitedUsers(
            limit: limitVisibleApps.map { [ListInvitedUsers.Limit.visibleApps($0)] },
            filter: filters
        )

        let result = service.request(endpoint)
            .map(\.data)
            .awaitResult()

        result.render(format: common.outputFormat)
    }
}
