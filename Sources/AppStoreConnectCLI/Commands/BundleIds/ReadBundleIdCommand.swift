// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct ReadBundleIdCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information about a specific bundle ID."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier to read. Must be unique. (eg. com.example.app)")
    var identifier: String

    func run() throws {
        let api = try makeClient()

        _ = try api
            .bundleIdResourceId(matching: identifier)
            .flatMap { api.request(APIEndpoint.readBundleIdInformation(id: $0)) }
            .map(BundleId.init)
            .renderResult(format: common.outputFormat)
    }
}
