// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct AddUserVisibleAppsCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "add-apps",
        abstract: "Give a user on your team access to one or more apps.")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "The username of the user to modify.")
    var username: String

    @Argument(help: "The list of bundle ids of apps to give access to.")
    var bundleIds: [String]

    public func run() throws {
        // TODO
        print(self.bundleIds)
    }
}
