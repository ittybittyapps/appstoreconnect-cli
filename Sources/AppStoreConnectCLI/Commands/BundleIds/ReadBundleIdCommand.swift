// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct ReadBundleIdCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information about a specific bundle ID."
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    @Argument(help: "The bundle ID to read. Must be unique.")
    var bundleId: String

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        _ = try api
            .findInternalIdentifier(for: bundleId)
            .flatMap {
                api.request(APIEndpoint.readBundleIdInformation(id: $0)).eraseToAnyPublisher()
            }
            .map(BundleId.init)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
