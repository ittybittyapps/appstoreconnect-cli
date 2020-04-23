// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

struct GetBuildInfoCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Get information about a specific build.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "An opaque resource ID that uniquely identifies the build")
    var buildId: String

    func run() throws {
        let service = try makeService()

        let request = APIEndpoint.build(withId: buildId)

        let build = try service.request(request)
            .map { $0.data }
            .await()

        build.render(format: common.outputFormat)
    }
}
