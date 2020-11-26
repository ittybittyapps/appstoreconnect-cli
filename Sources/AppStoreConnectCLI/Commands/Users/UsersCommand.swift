// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct UsersCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "users",
        abstract: "Manage users on your App Store Connect team.",
        subcommands: [
            AddUserVisibleAppsCommand.self,
            CancelUserInvitationsCommand.self,
            GetUserInfoCommand.self,
            InviteUserCommand.self,
            ListUserInvitationsCommand.self,
            // TODO: ListInvitedUserVisibleAppsCommand.self, // Get a list of apps that will be visible to a user with a pending invitation.
            ListUsersCommand.self,
            ListUserVisibleAppsCommand.self,
            ModifyUserInfoCommand.self,
            RemoveUserVisibleAppsCommand.self,
            SetUserVisibleAppsCommand.self,
            SyncUsersCommand.self,
        ],
        defaultSubcommand: ListUsersCommand.self
    )
}
