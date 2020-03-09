// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct InviteUserCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a user with assigned user roles to join your team.")

    @Argument(help: "The email address of a pending user invitation. The email address must be valid to activate the account. It can be any email address, not necessarily one associated with an Apple ID.")
    var email: String

    @Argument(help: "The user invitation recipient's first name.")
    var firstName: String

    @Argument(help: "The user invitation recipient's last name.")
    var lastName: String

    @Argument(help: "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.")
    var roles: [UserRole]

    @Flag(help: "Indicates that a user has access to all apps available to the team.")
    var allAppsVisible: Bool

    @Flag(help: "Indicates the user's specified role allows access to the provisioning functionality on the Apple Developer website.")
    var provisioningAllowed: Bool

    public func run() throws {
        // TODO
        print(self.email)
        print(self.firstName)
        print(self.lastName)
        print(self.roles)
    }
}
