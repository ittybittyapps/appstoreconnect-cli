// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
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
            return assignTesterToBuildIdsBy(api)
        }

        guard !groupNames.isEmpty else {
            fatalError("Invalid input, one or more build Id or beta group name is required when creating a tester")
        }

        let endpoint = APIEndpoint.betaGroups(
            filter: [ListBetaGroups.Filter.name(groupNames)]
        )

        _ = api.request(endpoint)
            .flatMap {
                api
                    .request(self.convertGroupsToEndpoint(groups: $0.data))
                    .eraseToAnyPublisher()
            }
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }

    private func assignTesterToBuildIdsBy(_ api: HTTPClient) {
        let endpoint = APIEndpoint.create(
            betaTesterWithEmail: email,
            firstName: firstName,
            lastName: lastName,
            buildIds: buildIds
        )

        _ = api.request(endpoint)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }

    private func convertGroupsToEndpoint(groups: [BetaGroup]) -> APIEndpoint<BetaTesterResponse> {
        let groupIds = groups.map { $0.id }

        if groupIds.isEmpty {
            fatalError("Invalid input, couldn't find any beta group with input names.")
        }

        return APIEndpoint.create(
            betaTesterWithEmail: email,
            firstName: firstName,
            lastName: lastName,
            betaGroupIds: groupIds
        )
    }
}
