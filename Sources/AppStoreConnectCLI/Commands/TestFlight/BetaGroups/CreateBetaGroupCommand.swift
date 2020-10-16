// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct CreateBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new beta group"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(
        help: """
        The reverse-DNS bundle ID of the app which the group should be associated with. \
        Must be unique. (eg. com.example.app)
        """
    ) var appBundleId: String

    @Argument(help: "The name for the beta group")
    var groupName: String

    @Flag(
        name: .customLong("public-link"),
        inversion: .prefixedNo,
        help: """
        Specifies whether or not a public link should be enabled. \
        Enabling a link allows you to invite anyone outside of your team to beta test your app. \
        When you share this link, testers will be able to install the beta version of your app \
        on their devices in TestFlight and share the link with others. \
        Defaults to false.
        """
    ) var publicLinkEnabled: Bool

    @Option(help: """
        The maximum number of testers that can join this beta group using the public link. \
        Values must be between 1 and 10,000. Optional.
        """
    ) var publicLinkLimit: Int?

    func run() throws {
        let service = try makeService()

        let betaGroup = try service.createBetaGroup(
            appBundleId: appBundleId,
            groupName: groupName,
            publicLinkEnabled: publicLinkEnabled,
            publicLinkLimit: publicLinkLimit
        )

        betaGroup.render(options: common.outputOptions)
    }
}
