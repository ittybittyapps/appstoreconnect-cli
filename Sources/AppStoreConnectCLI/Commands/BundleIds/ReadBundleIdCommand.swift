// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Bagbutik
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

    func run() async throws {
        let result = Model.BundleId(
            try await ReadBundleIdOperation(
                service: .init(authOptions: common.authOptions),
                options: .init(bundleId: identifier)
            )
            .execute()
        )
        
        result.render(options: common.outputOptions)
    }
}
