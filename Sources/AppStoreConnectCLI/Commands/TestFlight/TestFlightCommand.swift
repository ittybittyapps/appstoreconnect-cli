// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

public struct TestFlightCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "testflight",
        abstract: "Manage your beta testing program, including beta testers and groups, apps, and builds.",
        subcommands: [
            TestFlightAppsCommand.self,
            TestFlightBetaGroupCommand.self,
            TestFlightBetaTestersCommand.self,
            TestFlightBuildsCommand.self,
            TestFlightPreReleaseVersionCommand.self,
            TestFlightSyncCommand.self,
        ])

    public init() {
    }
}
