// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct ModifyBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Modify a beta group, only the specified options are modified"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(
        help: """
        The reverse-DNS bundle ID of the app which the group should be associated with. \
        Must be unique. (eg. com.example.app)
        """
    ) var appBundleId: String

    @Argument(
        help: ArgumentHelp(
            "The current name of the beta group to be modified",
            discussion: """
            This name will be used to search for a unique beta group matching the specified \
            app bundle id
            """,
            valueName: "beta-group-name"
        )
    ) var currentGroupName: String

    @Option(
        name: .customLong("name"),
        help: "Modifies the name of the beta group"
    ) var newGroupName: String?

    @Option(help: "Enables or disables the public link")
    var publicLinkEnabled: Bool?

    @Option(help: "Adjusts the public link limit")
    var publicLinkLimit: Int?

    @Option(help: "Enables or disables whether to use a public link limit")
    var publicLinkLimitEnabled: Bool?

    func run() throws {
    }
}
