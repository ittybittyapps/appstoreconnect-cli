// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct AppStoreConnectCLI: AsyncParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "asc",
        abstract: "A utility for interacting with the AppStore Connect API.",
        subcommands: [
            BundleIdsCommand.self,
            CapabilityCommand.self,
            CertificatesCommand.self,
            DevicesCommand.self,
            ProfilesCommand.self,
            ReportsCommand.self,
            TestFlightCommand.self,
            UsersCommand.self,
        ])

    public init() {
    }
}
