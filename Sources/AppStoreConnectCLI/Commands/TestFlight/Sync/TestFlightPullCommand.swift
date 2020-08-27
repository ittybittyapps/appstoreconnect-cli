// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem

struct TestFlightPullCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "pull",
        abstract: "Pull TestFlight configuration, overwriting local configuration files."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: "Filter by only including apps with the specified bundleIds in the configuration"
    ) var filterBundleIds: [String]

    @Option(
        default: "./config/apps",
        help: "Path to output/write the TestFlight configuration."
    ) var outputPath: String

    func run() throws {
        fatalError("Unimplemented command")
    }

}
