// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import struct Model.BundleId

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
        let service = try makeService()

        let bundleId = try service.readBundleIdInformation(bundleId: identifier)

        bundleId.render(format: common.outputFormat)
    }
}
