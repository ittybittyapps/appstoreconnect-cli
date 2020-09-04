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

        let testFlightProgram = try FileSystem.readTestFlightConfiguration(from: inputPath)

        // TODO: Push the testflight program to the API

        throw CommandError.unimplemented
    }

}
