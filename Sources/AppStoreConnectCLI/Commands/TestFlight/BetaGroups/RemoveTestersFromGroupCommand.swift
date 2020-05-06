// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct RemoveTestersFromGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "removeuser",
        abstract: "Remove beta testers from a beta group")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "Name of TestFlight beta tester group")
    var groupName: String

    @Argument(help: "Beta testers' email addresses")
    var emails: [String]

    func validate() throws {
        if emails.isEmpty {
            throw ValidationError("Missing expected argument '<emails>'.")
        }
    }

    func run() throws {
        let service = try makeService()

        try service.removeTestersFromGroup(groupName: groupName, emails: emails)
    }
}
