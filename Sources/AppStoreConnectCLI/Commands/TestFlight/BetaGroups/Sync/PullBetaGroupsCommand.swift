// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem

struct PullBetaGroupsCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "pull",
        abstract: "Pull down existing beta groups, refreshing local beta group config files"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/betagroups",
        help: "Path to the Folder containing the information about beta groups."
    ) var outputPath: String

    func run() throws {
        let service = try makeService()

        let betaGroupWithTesters = try service.pullBetaGroups()

        try BetaGroupProcessor(path: .folder(path: outputPath))
            .write(groupsWithTesters: betaGroupWithTesters)
    }

}
