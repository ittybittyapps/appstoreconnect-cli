// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct ListBetaTesterByGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "listbygroup",
        abstract: "List beta testers in a specific beta group for a specific app"
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var appLookupArgument: AppLookupArgument

    @Argument(
        help: ArgumentHelp(
            "TestFlight beta group name.",
            discussion: "Please input a specific group name"
        )
    )
    var groupName: String

    func run() async throws {
        let service = try makeService()

        let betaTesters = try await service.listBetaTestersForGroup(identifier: appLookupArgument.identifier, groupName: groupName)
        betaTesters.render(options: common.outputOptions)
    }
}
