// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct GetUserInfoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a user on your team, such as name, roles, and app visibility.")

    @Argument(help: "The userName of the user to find.")
    var name: String

    @Flag(help: "Whether or not to include visible app information.")
    var includeVisibleApps: Bool

    func run() throws {
        // TODO
        print(self.name as Any)
    }
}

