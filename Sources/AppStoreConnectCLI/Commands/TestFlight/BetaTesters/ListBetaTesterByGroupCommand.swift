// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import struct Model.BetaTester

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
            "TestFlight beta group names.",
            discussion: "Please input a specific group name"
        )
    )
    var groupName: String

    func run() throws {
        let service = try makeService()

        let betaTesters = try service.listBetaTestersForGroup(identifier: appLookupArgument.identifier, groupName: groupName)
        betaTesters.render(format: common.outputFormat)
    }
}
