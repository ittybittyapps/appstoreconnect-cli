// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

struct CreateBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a beta tester")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The beta tester's email address, used for sending beta testing invitations.")
    var email: String

    @Option(help: "The beta tester's first name.")
    var firstName: String?

    @Option(help: "The beta tester's last name.")
    var lastName: String?

    @Argument(help: "Array of opaque resource ID that uniquely identifies the resources.")
    var buildIds: [String]

    func run() throws {
        let api = try makeClient()

        let request = APIEndpoint.create(
            betaTesterWithEmail: email,
            firstName: firstName,
            lastName: lastName,
            buildIds: buildIds
        )

        _ = api.request(request)
            .map{ $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
