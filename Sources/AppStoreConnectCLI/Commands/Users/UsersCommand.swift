// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct UsersCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "users",
        abstract: "User commands",
        subcommands: [
            InviteUserCommand.self,
            ListUserInvitationsCommand.self,
            CancelUserInvitationsCommand.self,
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
