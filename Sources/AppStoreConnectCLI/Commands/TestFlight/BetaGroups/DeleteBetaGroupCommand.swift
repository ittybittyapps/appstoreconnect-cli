// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct DeleteBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a beta group"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(
        help: """
        The reverse-DNS bundle ID of the app which the group is associated with. \
        Must be unique. (eg. com.example.app)
        """
    ) var appBundleId: String

    @Argument(
        help: ArgumentHelp(
            "The name of the beta group to be deleted",
            discussion: """
            This name will be used to search for a unique beta group matching the specified \
            app bundle id
            """
        )
    ) var betaGroupName: String

    func run() throws {
        let service = try makeService()

        try service.deleteBetaGroup(appBundleId: appBundleId, betaGroupName: betaGroupName)
    }
}
