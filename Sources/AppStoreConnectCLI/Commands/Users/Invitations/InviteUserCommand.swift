// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct InviteUserCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a user with assigned user roles to join your team.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(
        help: ArgumentHelp(
            "The email address of a pending user invitation.",
            discussion: "The email address must be valid to activate the account. It can be any email address, not necessarily one associated with an Apple ID."
        )
    )
    var email: String

    @Argument(help: "The user invitation recipient's first name.")
    var firstName: String

    @Argument(help: "The user invitation recipient's last name.")
    var lastName: String

    @OptionGroup()
    var userInfo: UserInfoArguments

    public func run() throws {
        let service = try makeService()

        if userInfo.allAppsVisible {
            try inviteUserToTeam(by: service)
            return
        }

        if userInfo.bundleIds.isNotEmpty {
            let resourceIds = try service
                .getAppResourceIdsFrom(bundleIds: userInfo.bundleIds)
                .await()

            try inviteUserToTeam(with: resourceIds, by: service)
        }

        fatalError("Invalid Input: If you set allAppsVisible to false, you must provide at least one value for the visibleApps relationship.")
    }

    func inviteUserToTeam(with appsVisibleIds: [String] = [], by service: AppStoreConnectService) throws {
        let request = APIEndpoint.invite(
            userWithEmail: email,
            firstName: firstName,
            lastName: lastName,
            roles: userInfo.roles,
            allAppsVisible: userInfo.allAppsVisible,
            provisioningAllowed: userInfo.provisioningAllowed,
            appsVisibleIds: appsVisibleIds) // appsVisibleIds should be empty when allAppsVisible is true

        let invitation = try service.request(request)
            .map { $0.data }
            .await()

        invitation.render(options: common.outputOptions)
    }
}
