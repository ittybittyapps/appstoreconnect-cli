// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBuildCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information about a specific build.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "An opaque resource ID that uniquely identifies the build")
    var bundleId: String

    @Argument(help: "The build number of this build")
    var buildNumber: String

    @Argument(help: "The pre-release version number of this build")
    var preReleaseVersion: String

    func run() throws {
        let service = try makeService()

        let buildDetailsInfo = try service.readBuild(bundleId: bundleId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion)

        buildDetailsInfo.render(options: common.outputOptions)
    }
}
