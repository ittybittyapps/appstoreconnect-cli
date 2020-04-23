// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

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
            .bundleIdResourceId(matching: identifier)
            .flatMap { service.request(APIEndpoint.modifyBundleId(id: $0, name: self.name)) }
            .map(BundleId.init)
            .await()

        bundleId.render(format: common.outputFormat)
    }
}
