// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct GetUserInfoCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a user on your team, such as name, roles, and app visibility.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The email of the user to find.")
    var email: String

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

    func run() throws {
        let service = try makeService()

        let user = try service.getUserInfo(
            with: email,
            includeVisibleApps: includeVisibleApps
        )

        user.render(options: common.outputOptions)
    }
}
