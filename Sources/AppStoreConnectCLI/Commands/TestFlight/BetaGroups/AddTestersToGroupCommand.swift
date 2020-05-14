// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct AddTestersToGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "adduser",
        abstract: "Add testers to beta group"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    @Argument(help: "Name of TestFlight beta tester group.")
    var groupName: String

    @Argument(help: "Beta testers' email addresses.")
    var emails: [String]

    func validate() throws {
        if emails.isEmpty {
            throw ValidationError("Expected at least one email.")
        }
    }

    func run() throws {
        let service = try makeService()

        try service.addTestersToGroup(bundleId: bundleId, groupName: groupName, emails: emails)
    }
}
