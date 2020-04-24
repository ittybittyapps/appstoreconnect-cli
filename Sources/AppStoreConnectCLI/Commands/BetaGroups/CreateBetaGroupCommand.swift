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
        name: .customLong("publicLink"),
        inversion: .prefixedNo,
        help: """
        Specifies whether or not a public link should be enabled. \
        Enabling a link allows you to invite anyone outside of your team to beta test your app. \
        When you share this link, testers will be able to install the beta version of your app \
        on their devices in TestFlight and share the link with others. \
        Defaults to false.
        """
    ) var publicLinkEnabled: Bool

    func run() throws {
        let service = try makeService()
        let options = CreateBetaGroupOptions(appBundleId: appBundleId, groupName: groupName)
        let betaGroup = try service.createBetaGroup(with: options).await()

        betaGroup.render(format: common.outputFormat)
    }
}
