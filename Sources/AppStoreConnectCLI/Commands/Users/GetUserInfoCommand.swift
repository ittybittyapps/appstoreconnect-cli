// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct GetUserInfoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a user on your team, such as name, roles, and app visibility.")

    @OptionGroup()
    var authOptions: AuthOptions

    @Argument(help: "The email of the user to find.")
    var email: String

    @Flag(help: "Whether or not to include visible app information.")
    var includeVisibleApps: Bool

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let filters: [ListUsers.Filter] = [.username([email])]

        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        let request = APIEndpoint.users(filter: filters)

        _ = api.request(request)
            .map(User.fromAPIResponse)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }
}

