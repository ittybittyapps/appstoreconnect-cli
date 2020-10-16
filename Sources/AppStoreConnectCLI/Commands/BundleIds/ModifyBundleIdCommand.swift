// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import struct Model.BundleId

struct ModifyBundleIdCommand: CommonParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Update a specific bundle ID's name."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier. (eg. com.example.app)")
    var identifier: String

    @Argument(help: "The new name for the bundle identifier.")
    var name: String

    func run() throws {
        let service = try makeService()

        let bundleId = try service
            .modifyBundleIdInformation(bundleId: identifier, name: name)

        bundleId.render(options: common.outputOptions)
    }
}
