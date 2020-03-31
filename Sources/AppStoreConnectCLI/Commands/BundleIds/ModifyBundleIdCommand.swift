// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct ModifyBundleIdCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Update a specific bundle ID's name."
    )

    @OptionGroup()
    var authOptions: AuthOptions

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    @Option(help: "The unique identifier of the bundle ID.")
    var identifier: String

    @Option(help: "The new name for the bundle identifier.")
    var name: String

    func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        _ = try api
            .findInternalIdentifier(for: identifier)
            .flatMap { internalId in
                api.request(APIEndpoint.modifyBundleId(id: internalId, name: self.name)).eraseToAnyPublisher()
            }
            .map(BundleId.init)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
