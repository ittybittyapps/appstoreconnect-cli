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

    @Argument(help: "The beta tester's email address, used for sending beta testing invitations.")
    var email: String

    @Option(help: "The beta tester's first name.")
    var firstName: String?

    @Option(help: "The beta tester's last name.")
    var lastName: String?

    @Argument(help: "Array of opaque resource ID that uniquely identifies the resources.")
    var buildIds: [String]

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

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
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
