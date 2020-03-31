// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct SetUserVisibleAppsCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "set-apps",
        abstract: "Set the list of apps a user on your team can see.")

    @Argument(help: "The username of the user to modify.")
    var username: String

    @Argument(help: "The list of bundle ids of apps to set for the user.")
    var bundleIds: [String]

    public func run() throws {
        // TODO
        print(self.bundleIds)
    }
}
