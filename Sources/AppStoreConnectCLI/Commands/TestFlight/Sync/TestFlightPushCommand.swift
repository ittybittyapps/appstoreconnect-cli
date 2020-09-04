// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem
import Model

struct TestFlightPushCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "push",
        abstract: "Push local TestFlight configuration to the remote API."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/apps",
        help: "Path to read in the TestFlight configuration."
    ) var inputPath: String

    enum SyncAction {
        case addBetaGroup(BetaGroup)
        case removeBetaGroup(BetaGroup)
        case addBetaTester(BetaTester, toBetaGroups: [BetaGroup])
        case removeBetaTester(BetaTester, fromBetaGroups: [BetaGroup])
    }

    func run() throws {
        let localTestFlightProgram = try FileSystem.readTestFlightConfiguration(from: inputPath)

        let service = try makeService()
        let remoteTestFlightProgram = try service.getTestFlightProgram()

        // TODO: Compare local and remote Program

        // TODO: Push the testflight program to the API

        throw CommandError.unimplemented
    }

}
