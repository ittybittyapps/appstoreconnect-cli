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

    @OptionGroup()
    var authOptions: AuthOptions

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    @Argument(help: "The unique identifier of the bundle ID.")
    var identifier: String

    func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        _ = try api
            .findInternalIdentifier(for: identifier)
            .flatMap { internalId in
                api.request(APIEndpoint.readBundleIdInformation(id: internalId)).eraseToAnyPublisher()
            }
            .map(BundleId.init)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
