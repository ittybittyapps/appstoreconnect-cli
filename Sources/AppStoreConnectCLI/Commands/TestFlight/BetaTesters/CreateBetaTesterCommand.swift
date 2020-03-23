// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

struct CreateBetaTesterCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a beta tester")

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "the first name of beta tester")
    var firstName: String

    @Argument(help: "the last name of beta tester")
    var lastName: String

    func run() throws {
        print(firstName)
        print(lastName)
    }
}
