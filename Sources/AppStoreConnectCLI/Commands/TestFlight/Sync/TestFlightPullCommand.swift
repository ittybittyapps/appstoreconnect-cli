// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem

struct TestFlightPullCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "pull",
        abstract: "Pull down existing TestFlight configuration, refreshing local configuration files."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/apps",
        help: "Path to the folder containing the TestFlight configuration."
    ) var outputPath: String

    func run() throws {
        let service = try makeService()

        let configs = try service.pullTestFlightConfigurations()

        try configs.save(in: outputPath)
    }

}
