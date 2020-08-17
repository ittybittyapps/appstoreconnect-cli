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

    @Flag(name: .shortAndLong, help: "Display less messaging in standard output.")
    var quiet: Bool
}
