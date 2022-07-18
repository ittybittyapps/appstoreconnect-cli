// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK

import ArgumentParser
import Foundation
import Model

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

    func validate() throws {
        if userInfo.allAppsVisible == false && userInfo.bundleIds.isEmpty {
            throw ValidationError.init("If you set allAppsVisible to false, you must provide at least one value for the visibleApps relationship.")
        }
    }
    
    public func run() async throws {
        let service = try makeService()

        let invitation: Model.UserInvitation
        
        if userInfo.allAppsVisible {
            invitation = try await service.inviteUserToTeam(
                email: email,
                firstName: firstName,
                lastName: lastName,
                roles: userInfo.roles,
                allAppsVisible: userInfo.allAppsVisible,
                provisioningAllowed: userInfo.provisioningAllowed
            )
        } else {
            let resourceIds = try await service
                .appResourceIdsForBundleIds(userInfo.bundleIds)

            guard resourceIds.isEmpty == false else {
                throw AppError.couldntFindApp(bundleId: userInfo.bundleIds)
            }
                        
            invitation = try await service.inviteUserToTeam(
                email: email,
                firstName: firstName,
                lastName: lastName,
                roles: userInfo.roles,
                allAppsVisible: userInfo.allAppsVisible,
                provisioningAllowed: userInfo.provisioningAllowed,
                appsVisibleIds: resourceIds
            )
        }
       
        invitation.render(options: common.outputOptions)
    }

}

private enum AppError: LocalizedError {
    case couldntFindApp(bundleId: [String])

    var errorDescription: String? {
        switch self {
        case .couldntFindApp(let bundleIds):
            return "No apps were found matching \(bundleIds)."
        }
    }
}
