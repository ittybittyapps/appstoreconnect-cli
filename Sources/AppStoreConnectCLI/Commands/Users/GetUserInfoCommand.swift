// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct GetUserInfoCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a user on your team, such as name, roles, and app visibility.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The email of the user to find.")
    var email: String

    @Flag(help: "Whether or not to include visible app information.")
    var includeVisibleApps: Bool

    func run() throws {
        let filters: [ListUsers.Filter] = [.username([email])]

        let api = makeClient()

        let request = APIEndpoint.users(filter: filters)

        _ = api.request(request)
            .map(User.fromAPIResponse)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}

