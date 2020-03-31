// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct RegisterBundleIdCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "register",
        abstract: "Register a new bundle ID for app development."
    )

    @OptionGroup()
    var authOptions: AuthOptions

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    @Option(help: "An opaque resource ID that uniquely identifies the bundle identifier.")
    var identifier: String

    @Option(help: "The new name for the bundle identifier.")
    var name: String

    @Option(
        help: "The platform of the bundle identifier (\(BundleIdPlatform.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", ")))."
    )
    var platform: BundleIdPlatform

    func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        let request = APIEndpoint.registerNewBundleId(id: identifier, name: name, platform: platform)

        _ = api.request(request)
            .map(BundleId.init(response:))
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}
