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

    func run() throws {
        let api = try makeClient()

        _ = try api
            .betaTesterIdentifier(matching: email)
            .flatMap {
                api.request(APIEndpoint.betaTester(
                    withId: $0,
                    include: [GetBetaTester.Include.apps, GetBetaTester.Include.betaGroups]
                ))
            }
            .map(\.data)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: self.common.outputFormat).render
            )
    }
}
