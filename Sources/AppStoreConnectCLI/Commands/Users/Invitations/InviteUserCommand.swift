// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct InviteUserCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a user with assigned user roles to join your team.")

    @OptionGroup()
    var authOptions: AuthOptions

    @Argument(help: "The email address of a pending user invitation. The email address must be valid to activate the account. It can be any email address, not necessarily one associated with an Apple ID.")
    var email: String

    @Argument(help: "The user invitation recipient's first name.")
    var firstName: String

    @Argument(help: "The user invitation recipient's last name.")
    var lastName: String

    @Option(parsing: .upToNextOption, help: "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.")
    var roles: [UserRole]

    @Flag(help: "Indicates that a user has access to all apps available to the team.")
    var allAppsVisible: Bool

    @Flag(help: "Indicates the user's specified role allows access to the provisioning functionality on the Apple Developer website.")
    var provisioningAllowed: Bool

    @Option(parsing: .upToNextOption,
            help: "Array of bundle IDs that uniquely identifies the apps.")
    var bundleIds: [String]

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    public func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        if allAppsVisible {
            inviteUserToTeam(by: api)
            return
        }

        if !bundleIds.isEmpty {
            _ = api
                .getResourceIdsFrom(bundleIds: bundleIds, by: api)
                .sink(receiveCompletion: Renderers.CompletionRenderer().render) {
                    self.inviteUserToTeam(with: $0, by: api)
                }
        }

        fatalError("Invalid Input: If you set allAppsVisible to false, you must provide at least one value for the visibleApps relationship.")
    }

    func inviteUserToTeam(with appsVisibleIds: [String] = [], by api: HTTPClient) {
        let request = APIEndpoint.invite(
            userWithEmail: email,
            firstName: firstName,
            lastName: lastName,
            roles: roles,
            allAppsVisible: allAppsVisible,
            provisioningAllowed: provisioningAllowed,
            appsVisibleIds: appsVisibleIds) // appsVisibleIds should be empty when allAppsVisible is true

        _ = api.request(request)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
