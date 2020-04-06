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

    private enum CommandError: Error, CustomStringConvertible {
        case invalidInput, couldntFindBetaGroup

        var description: String {
            switch self {
            case .invalidInput:
                return "Invalid input, one or more build Id or beta group name is required when creating a tester"

            case .couldntFindBetaGroup:
                return "Couldn't find any beta group with input names."
            }
        }
    }

    func run() throws {
        let api = try makeClient()

        let request: AnyPublisher<BetaTesterResponse, Error>

        let createWithBuildIds = { ids -> APIEndpoint<BetaTesterResponse> in
            .create(betaTesterWithEmail: self.email, firstName: self.firstName, lastName: self.lastName, buildIds: ids)
        }

        let createWithGroupIds = { ids -> APIEndpoint<BetaTesterResponse> in
            .create(betaTesterWithEmail: self.email, firstName: self.firstName, lastName: self.lastName, betaGroupIds: ids)
        }

        switch (buildIds, groupNames) {
            case (let buildIds, _) where !buildIds.isEmpty:
                let endpoint = createWithBuildIds(buildIds)
                request = api.request(endpoint).eraseToAnyPublisher()

            case (_, let groupNames) where !groupNames.isEmpty:
                let endpoint = APIEndpoint.betaGroups(filter: [ListBetaGroups.Filter.name(groupNames)])

                let groupIds = api.request(endpoint).map { $0.data.map(\.id) }

                request = groupIds
                    .flatMap { (groupIds: [String]) -> AnyPublisher<BetaTesterResponse, Error> in
                        guard !groupIds.isEmpty else {
                            return Fail(error: CommandError.couldntFindBetaGroup).eraseToAnyPublisher()
                        }

                        let endpoint = createWithGroupIds(groupIds)

                        return api.request(endpoint).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            case (_, _):
                request = Fail(error: CommandError.invalidInput as Error).eraseToAnyPublisher()
        }

        _ = request
            .map(\.data)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
