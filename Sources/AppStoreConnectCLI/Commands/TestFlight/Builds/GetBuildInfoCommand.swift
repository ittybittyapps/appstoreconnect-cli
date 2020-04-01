// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

struct GetBuildInfoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a specific build.")

    @OptionGroup()
    var authOptions: AuthOptions

    @Argument(help: "An opaque resource ID that uniquely identifies the build")
    var buildId: String

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        let request = APIEndpoint.build(withId: buildId)

        _ = api.request(request)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: self.outputFormat).render
            )
    }
}
