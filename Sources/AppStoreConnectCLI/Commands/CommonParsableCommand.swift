// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

protocol CommonParsableCommand: ParsableCommand {
    var common: CommonOptions { get }

    func makeService() throws -> AppStoreConnectService
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

    /// Used to print status messages. Defaults to `false`, except for `--table`, so all commands are parsable by default.
    @Flag(name: .shortAndLong, help: "Display extra messages as command is running.")
    var verbose: Bool
}
