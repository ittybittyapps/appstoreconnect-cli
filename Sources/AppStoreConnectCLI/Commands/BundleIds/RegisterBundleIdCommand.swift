// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import ArgumentParser
import Foundation
import struct Model.BundleId

struct RegisterBundleIdCommand: CommonParsableCommand {
    
    typealias Platform = Bagbutik.BundleIdPlatform
    
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
        help: "The platform of the bundle identifier. One of \(Platform.allValueStrings.formatted(.list(type: .or))).",
        completion: .list(Platform.allValueStrings)
    )
    var platform: Platform = .universal

    func run() async throws {
        
        let result = Model.BundleId(
            try await RegisterBundleIdOperation(
                service: .init(authOptions: common.authOptions),
                options: .init(bundleId: identifier, name: name, platform: platform)
            )
            .execute()
        )

        result.render(options: common.outputOptions)
    }
}
