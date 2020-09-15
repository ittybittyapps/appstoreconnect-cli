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

    func run() throws {
        let service = try makeService()

        let local = try FileSystem.readTestFlightConfiguration(from: inputPath)
        let remote = try service.getTestFlightProgram()

        let difference = TestFlightProgramDifference(local: local, remote: remote)

        difference.changes.forEach { print($0.description) }

        // TODO: Push the testflight program to the API

        throw CommandError.unimplemented
    }

}
