// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBuildsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list builds for all apps in App Store Connect.")

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: "An opaque resource ID that uniquely identifies the build"
    )
    var bundleId: [String]

    @Option(
        parsing: .upToNextOption,
        help: "A boolean value to indicate whether the build is expired (true or false)"
    )
    var expired: [String]

    @Option(
        parsing: .upToNextOption,
        help: "The pre-release version number of this build"
    )
    var preReleaseVersion: [String]

    @Option(
        parsing: .upToNextOption,
        help: "The build number of the builds"
    )
    var buildNumber:[String]

    @Option(
        parsing: .upToNextOption,
        help: "The processing state of the builds"
    )
    var processingState: [String]

    @Option(
        parsing: .upToNextOption,
        help: "The beta review state of the builds"
    )
    var betaReviewState: [String]

    @Option(help: "Limit the number of individualTesters & betaBuildLocalizations")
    var limit: Int?

    
    func run() throws {
        let service = try makeService()

        let builds = try service.listBuilds(bundleId: bundleId, expired: expired, preReleaseVersion: preReleaseVersion, buildNumber: buildNumber, betaReviewState: betaReviewState, limit: limit)

        builds.render(format: common.outputFormat)
    }
}
