// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import ArgumentParser

struct ListBuildsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "builds",
        abstract: "Find and list builds for all apps in App Store Connect"
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String
    
    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        let request = APIEndpoint.builds()

        _  = api.request(request)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
