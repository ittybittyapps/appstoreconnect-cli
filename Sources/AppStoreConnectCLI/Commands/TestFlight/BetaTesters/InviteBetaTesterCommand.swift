// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct InviteBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a beta tester and assign them to one or more groups")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The beta tester's email address, used for sending beta testing invitations.")
    var email: String

    @Argument(help: "The beta tester's first name.")
    var firstName: String?

    @Argument(help: "The beta tester's last name.")
    var lastName: String?

    @Argument(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    @Option(parsing: .upToNextOption,
            help: "Names of TestFlight beta tester group that the tester will be assigned to.")
    var groups: [String]

    func run() throws {
        let service = try makeService()

        let options = InviteBetaTesterOptions(
            firstName: firstName,
            lastName: lastName,
            email: email,
            bundleId: bundleId,
            groupNames: groups
        )

        let betaTester = try service
            .inviteBetaTesterToGroups(with: options)

        betaTester.render(format: common.outputFormat)
    }
}
