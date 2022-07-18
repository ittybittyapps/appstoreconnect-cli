// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Model

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
    var filterEmail: [String] = []

    @Option(parsing: .upToNextOption, help: "Filter the results by the specified roles, (eg. \(UserRole.allCases.compactMap { $0.rawValue.lowercased() })")
    var filterRole: [UserRole] = []

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps = false

    public func run() async throws {
        let service = try makeService()

        let invitations = try await service.listUserInvitaions(
            filterEmail: filterEmail,
            filterRole: filterRole,
            limitVisibleApps: limitVisibleApps,
            includeVisibleApps: includeVisibleApps
        )

        invitations.render(options: common.outputOptions)
    }
}
