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
        let api = try makeClient()

        _ = try api
            .bundleIdResourceId(matching: identifier)
            .flatMap { internalId in
                api.request(APIEndpoint.modifyBundleId(id: internalId, name: self.name))
            }
            .map(BundleId.init)
            .renderResult(format: common.outputFormat)            
    }
}
