// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct RemoveUserVisibleAppsCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "remove-apps",
        abstract: "Remove a user on your team's access to one or more apps.")

    @Argument(help: "The username of the user to modify.")
    var username: String

    @Argument(help: "The list of bundle ids of apps to remove access to.")
    var bundleIds: [String]

    public func run() throws {
        // TODO
        print(self.bundleIds)
    }
}
