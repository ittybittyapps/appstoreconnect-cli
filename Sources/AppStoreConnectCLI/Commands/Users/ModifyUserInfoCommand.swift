// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ModifyUserInfoCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Change a user's role, app visibility information, or other account details.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The email of the user to find.")
    var email: String

    @OptionGroup()
    var userInfo: UserInfoArguments

    func validate() throws {
        if userInfo.bundleIds.isEmpty && userInfo.allAppsVisible == false {
            throw ValidationError("Invalid Input: If you set allAppsVisible to false, you must provide at least one value for the visibleApps relationship.")
        }
    }

    func run() throws {
        let service = try makeService()

        let user = try service.modifyUserInfo(
            email: email,
            roles: userInfo.roles,
            allAppsVisible: userInfo.allAppsVisible,
            provisioningAllowed: userInfo.provisioningAllowed,
            bundleIds: userInfo.bundleIds
        )

        user.render(options: common.outputOptions)
    }
}
