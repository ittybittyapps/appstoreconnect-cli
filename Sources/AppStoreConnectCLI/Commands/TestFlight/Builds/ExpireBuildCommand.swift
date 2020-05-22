// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ExpireBuildCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "expire",
        abstract: "Expire a build.")

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    func run() throws {
        let service = try makeService()

        _ = try service.expireBuild(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion
        )
    }
}
