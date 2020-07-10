// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem

struct TestFlightPullCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "pull",
        abstract: "Pull down existing testflight configs, refreshing local config files"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/apps",
        help: "Path to the Folder containing the testflight configs."
    ) var outputPath: String

    func run() throws {
        let service = try makeService()

        let configs = try service.pullTestFlightConfigs()

        configs.forEach {
            print($0.app.name)
            print($0.betagroups.count)
        }

        try TestFlightConfigLoader().save(configs, in: outputPath)
    }

}
