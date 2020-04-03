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

    @Option(help: "Array of opaque resource ID that uniquely identifies the builds for an application.")
    var buildIds: [String]

    @Option(help: "Names of TestFlight beta tester group that the tester will be assigned to")
    var groupNames: [String]
    func run() throws {
        let api = try makeClient()

        if !buildIds.isEmpty {
            let endpoint = APIEndpoint.create(
                betaTesterWithEmail: email,
                firstName: firstName,
                lastName: lastName,
                buildIds: buildIds
            )
            createTesters(through: endpoint, by: api)
            return
        }

        if !groupNames.isEmpty {
            let endpoint = APIEndpoint.betaGroups(filter: [ListBetaGroups.Filter.name(groupNames)])

            _ = api.request(endpoint)
                .map { $0.data }
                .sink(
                    receiveCompletion: Renderers.CompletionRenderer().render,
                    receiveValue: {
                        let groupIds = $0.map { $0.id }

                        if groupIds.isEmpty {
                            fatalError("Invalid input, couldn't find any beta group with input names.")
                        }

                        let endpoint = APIEndpoint.create(
                            betaTesterWithEmail: self.email,
                            firstName: self.firstName,
                            lastName: self.lastName,
                            betaGroupIds: groupIds
                        )
                        self.createTesters(through: endpoint, by: api)
                    }
                )
            return
        }

        fatalError("Invalid input, one or more build Id or beta group name is required when creating a tester")
    }

    func createTesters(through endpoint: APIEndpoint<BetaTesterResponse>,
                       by api: HTTPClient) {
        _ = api.request(endpoint)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
