// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListUserVisibleAppsCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "list-apps",
        abstract: "Get a list of apps that a user on your team can view.")

    @Argument(help: "The username of the user to list the apps for.")
    var username: String

    @Option(help: "Limit the number of apps to return (maximum 200).")
    var limit: Int?

    public func run() throws {
        // TODO
        print(self.username as Any)
    }
}
