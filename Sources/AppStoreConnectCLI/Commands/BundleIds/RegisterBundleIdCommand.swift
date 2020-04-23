// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct RegisterBundleIdCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "register",
        abstract: "Register a new bundle ID for app development."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier. Must be unique. (eg. com.example.app)")
    var identifier: String

    @Argument(help: "The new name for the bundle identifier.")
    var name: String

    @Option(
        default: .universal,
        help: "The platform of the bundle identifier \(BundleIdPlatform.allCases)."
    )
    var platform: BundleIdPlatform

    func run() throws {
        let service = try makeService()

        let request = APIEndpoint.registerNewBundleId(id: identifier, name: name, platform: platform)

        let bundleId = try service.request(request)
            .map(BundleId.init)
            .await()

        bundleId.render(format: common.outputFormat)
    }
}
