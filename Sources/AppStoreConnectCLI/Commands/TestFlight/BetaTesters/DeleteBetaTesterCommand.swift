// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
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

    @Option(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String
//
//    @Option(help: "The ID of one build of an application")
//    var buildId: String
//
//    @Option(help: "The name of the beta group that the tester will be remove from")
//    var betaGroupName: String

    func run() throws {
        let api = try makeClient()

        // Remove a beta tester's ability to test all apps.
        if all {
            _ = api
            .betaTesterIdentifier(matching: email)
            .flatMap {
                api.request(APIEndpoint.delete(betaTesterWithId: $0)).eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { _ in }
            )
            return
        }

        // Remove a specific beta tester's access to test any builds of one or more apps.
        if !bundleId.isEmpty {
            _ = api
                .betaTesterIdentifier(matching: email)
                .combineLatest(api.getAppResourceIdsFrom(bundleIds: [bundleId]))
                .flatMap {
                    api.request(APIEndpoint.remove(accessOfBetaTesterWithId: $0, toAppsWithIds: $1))
                }
                .sink(
                    receiveCompletion: Renderers.CompletionRenderer().render,
                    receiveValue: { _ in }
                )
            return
        }

        // Remove access to test a specific build from one or more individually assigned testers.
//        APIEndpoint.remove(individualTestersWithIds: <#T##[String]#>, fromBuildWithId: <#T##String#>)

        // Remove a specific beta tester from one or more beta groups, revoking their access to test builds associated with those groups.
//        APIEndpoint.remove(betaTestersWithIds: <#T##[String]#>, fromBetaGroupWithId: <#T##String#>)
    }
}
