// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaTesterInfoCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
    commandName: "info",
    abstract: "Get information about a beta tester")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The Beta tester's email address")
    var email: String

    @Option(help: "Number of included app resources to return.")
    var limitApps: Int?

    @Option(help: "Number of included build resources to return.")
    var limitBuilds: Int?

    @Option(help: "Number of included beta group resources to return.")
    var limitBetaGroups: Int?

    func run() throws {
        let api = try makeClient()

        var limits: [GetBetaTester.Limit] = []

        if let limitApps = limitApps {
            limits.append(GetBetaTester.Limit.apps(limitApps))
        }

        if let limitBuilds = limitBuilds {
            limits.append(GetBetaTester.Limit.builds(limitBuilds))
        }

        if let limitBetaGroups = limitBetaGroups {
            limits.append(GetBetaTester.Limit.betaGroups(limitBetaGroups))
        }

        _ = try api
            .betaTesterResourceId(matching: email)
            .flatMap {
                api.request(APIEndpoint.betaTester(
                    withId: $0,
                    include: [GetBetaTester.Include.apps, GetBetaTester.Include.betaGroups],
                    limit: limits
                ))
            }
            .map { BetaTester.init($0.data, $0.included) }
            .renderResult(format: common.outputFormat)
    }
}
