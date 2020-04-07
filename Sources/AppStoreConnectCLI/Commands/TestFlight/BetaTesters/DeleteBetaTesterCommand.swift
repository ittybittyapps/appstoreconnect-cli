// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DeleteBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a beta tester")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The beta tester's email address")
    var email: String

    @Flag(help: "Remove a beta tester’s ability to test all apps.")
    var all: Bool

    @Option(default:"",
            help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    @Option(default: "",
            help: "The name of the beta group that the tester will be remove from")
    var betaGroupName: String

    @Option(default: "",
            help: "The ID of one build of an application")
    var buildId: String

    private enum CommandError: Error, CustomStringConvertible {
        case invalidInput

        var description: String {
            switch self {
                case .invalidInput:
                    return "Invalid input, one of these options or flag is required when deleting a tester"
            }
        }
    }

    private enum DeleteStrategy {
        case all
        case removeFromApp(bundleId: String)
        case removeFromGroup(betaGroupName: String)
        case removeFromBuild(buildId: String)
        case error(error: Error)

        init(_ all: Bool, _ bundleId: String, _ betaGroupName: String, _ buildId: String) {
            switch (all, bundleId, betaGroupName, buildId) {
                case (true, _, _, _):
                    self = .all
                case (false, let bundleId, _, _) where !bundleId.isEmpty:
                    self = .removeFromApp(bundleId: bundleId)
                case (false, _, let betaGroupName, _) where !betaGroupName.isEmpty:
                    self = .removeFromGroup(betaGroupName: betaGroupName)
                case (false, _, _, let buildId) where !buildId.isEmpty:
                    self = .removeFromBuild(buildId: buildId)
                case (false, _, _, _):
                    self = .error(error: CommandError.invalidInput)
            }
        }
    }

    func run() throws {
        let api = try makeClient()

        let request: AnyPublisher<Void, Error>

        switch DeleteStrategy(all, bundleId, betaGroupName, buildId) {
            // Remove a beta tester's ability to test all apps.
            case .all:
                request = try api
                    .betaTesterIdentifier(matching: email)
                    .flatMap {
                        api.request(APIEndpoint.delete(betaTesterWithId: $0)).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()

            // Remove a specific beta tester's access to test any builds of one or more apps.
            case .removeFromApp(let bundleId):
                request = try api
                    .betaTesterIdentifier(matching: email)
                    .combineLatest(api.getAppResourceIdsFrom(bundleIds: [bundleId]))
                    .flatMap {
                        api.request(APIEndpoint.remove(accessOfBetaTesterWithId: $0, toAppsWithIds: $1))
                    }
                    .eraseToAnyPublisher()

            // Remove a specific beta tester from one or more beta groups, revoking their access to test builds associated with those groups.
            case .removeFromGroup(let betaGroupName):
                request = try api
                    .betaTesterIdentifier(matching: email)
                    .combineLatest(try api.betaGroupIdentifier(matching: betaGroupName))
                    .flatMap {
                        api.request(APIEndpoint.remove(
                            betaTestersWithIds: [$0],
                            fromBetaGroupWithId: $1
                        ))
                    }
                    .eraseToAnyPublisher()

            // Remove access to test a specific build from one or more individually assigned testers.
            case .removeFromBuild(let buildId):
                request = try api
                    .betaTesterIdentifier(matching: email)
                    .flatMap {
                        api.request(APIEndpoint.remove(
                            individualTestersWithIds: [$0],
                            fromBuildWithId: buildId
                        ))
                    }
                    .eraseToAnyPublisher()

            case .error(let error):
                request = Fail(error: error).eraseToAnyPublisher()
        }

        _ = request
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { _ in }
            )
    }
}
