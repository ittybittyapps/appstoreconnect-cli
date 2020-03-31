// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct UsersCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "users",
        abstract: "User commands",
        subcommands: [
            InviteUserCommand.self,
            // TODO: GetUserInvitationInfoCommand.self, // Get information about a pending invitation to join your team.
            // TODO: CancelUserInvitationCommand.self, // Cancel a pending invitation for a user to join your team.
            // TODO: ListInvitedUserVisibleAppsCommand.self, // Get a list of apps that will be visible to a user with a pending invitation.
            ListUsersCommand.self,
            GetUserInfoCommand.self,
            ListUserVisibleAppsCommand.self,
            AddUserVisibleAppsCommand.self,
            RemoveUserVisibleAppsCommand.self,
            SetUserVisibleAppsCommand.self,
            SyncUsersCommand.self
        ],
        defaultSubcommand: ListUsersCommand.self
    )
}
