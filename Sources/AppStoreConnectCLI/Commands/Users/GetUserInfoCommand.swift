// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct GetUserInfoCommand: ParsableCommand, UserOutputBuilder {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a user on your team, such as name, roles, and app visibility.")

    @Option(default: "../config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "The email of the user to find.")
    var email: String

    @Flag(help: "Whether or not to include visible app information.")
    var includeVisibleApps: Bool

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let filters: [ListUsers.Filter] = [.username([email])]

        let api = try HTTPClient(auth: auth)

        let request = APIEndpoint.users(filter: filters)

        _ = api.request(request)
            .map { $0.data.compactMap(User.fromAPIUser) }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print(String(describing: error))
                }
            }, receiveValue: { [output, includeVisibleApps] users in
                output(users, includeVisibleApps)
            })
    }
}

