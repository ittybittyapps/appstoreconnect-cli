// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct InviteUserCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a user with assigned user roles to join your team.")

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "The email address of a pending user invitation. The email address must be valid to activate the account. It can be any email address, not necessarily one associated with an Apple ID.")
    var email: String

    @Argument(help: "The user invitation recipient's first name.")
    var firstName: String

    @Argument(help: "The user invitation recipient's last name.")
    var lastName: String

    @Option(parsing: ArrayParsingStrategy.singleValue, help: "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.")
    var roles: [UserRole]

    @Flag(help: "Indicates that a user has access to all apps available to the team.")
    var allAppsVisible: Bool

    @Flag(help: "Indicates the user's specified role allows access to the provisioning functionality on the Apple Developer website.")
    var provisioningAllowed: Bool

    @Option(parsing: ArrayParsingStrategy.singleValue,
            help: "Array of opaque resource ID that uniquely identifies the resources.")
    var appsVisibleIds: [String?]

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    public func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        let request = APIEndpoint.invite(
            userWithEmail: email,
            firstName: firstName,
            lastName: lastName,
            roles: roles,
            allAppsVisible: allAppsVisible,
            provisioningAllowed: provisioningAllowed,
            appsVisibleIds: allAppsVisible ? [] : appsVisibleIds.compactMap{ $0 }) // appsVisibleIds should not have value when allAppsVisible is true

        _ = api.request(request)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
