// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct AddTesterToGroupsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "addgroup",
        abstract: "Add tester to one or more groups"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "Beta testers' email address.")
    var email: String

    @Argument(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    @Argument(help: "Name of TestFlight beta tester group.")
    var groupNames: [String]

    func validate() throws {
        if groupNames.isEmpty {
            throw ValidationError("Expected at least one group name.")
        }
    }

    func run() throws {
        let service = try makeService()

        try service.addTesterToGroups(email: email, bundleId: bundleId, groupNames: groupNames)
    }
}
