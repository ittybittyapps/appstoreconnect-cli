// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

protocol CommonParsableCommand: ParsableCommand {
    var common: CommonOptions { get }

    func makeService() throws -> AppStoreConnectService
}

/// A level representing the verbosity of a command.
enum PrintLevel {
    // Withholds displaying normal status messages
    case quiet
    // Displays all status messages
    case verbose
}

extension CommonParsableCommand {
    func makeService() throws -> AppStoreConnectService {
        AppStoreConnectService(configuration: try APIConfiguration(common.authOptions))
    }
}

struct CommonOptions: ParsableArguments {
    @OptionGroup()
    var authOptions: AuthOptions

    @Flag(default: .table, help: "Display results in specified format.")
    var outputFormat: OutputFormat

    /// The verbosity of the executed command.
    var printLevel: PrintLevel {
        // Commands are parsable by default except for `--table` which is intended to be interactive.
        switch (verbose, outputFormat == .table) {
            // if `--verbose` or `--table`is used then return a verbose print level
            case (true, _), (_, true):
                return .verbose
            // if both `--verbose` and `--table` are not used, then return a quiet print level
            case (false, false):
                return .quiet
        }
    }

    /// Used to define the command's `PrintLevel`. Defaults to `false`.
    @Flag(name: .shortAndLong, help: "Display extra messages as command is running.")
    var verbose: Bool
}
