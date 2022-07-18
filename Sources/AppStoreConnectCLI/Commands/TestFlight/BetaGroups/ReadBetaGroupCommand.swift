// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct ReadBetaGroupCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Read a beta group"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(
        help: """
        The reverse-DNS bundle ID of the app which the group should be associated with. \
        Must be unique. (eg. com.example.app)
        """
    ) var appBundleId: String

    @Argument(help: "The name of the beta group.")
    var groupName: String

    func run() async throws {
        let service = try makeService()

        let betaGroup = try await service.readBetaGroup(bundleId: appBundleId, groupName: groupName)

        betaGroup.render(options: common.outputOptions)
    }
}
