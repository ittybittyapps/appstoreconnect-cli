// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct RemoveBuildFromGroupsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "removebetagroup",
        abstract: "Remove access to a specific build for all beta testers in one or more beta groups")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "App bundle identifier. eg. com.example.App")
    var bundleId: String

    @Argument(help: "The pre-release version number of this build.")
    var preReleaseVersion: String

    @Argument(help: "The build number of this build.")
    var buildNumber: String

    @Argument(help: "Names of beta groups.")
    var groupNames: [String]

    func validate() throws {
        if groupNames.isEmpty {
            throw ValidationError("Excepted at least one group name.'")
        }
    }

    func run() throws {
        let service = try makeService()

        try service.removeBuildFromGroups(
            bundleId: bundleId,
            version: preReleaseVersion,
            buildNumber: buildNumber,
            groupNames: groupNames
        )
    }
}
