// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

protocol CommonParsableCommand: ParsableCommand {
    var common: CommonOptions { get }

    func makeClient() throws -> HTTPClient
}

extension CommonParsableCommand {
    func makeClient() throws -> HTTPClient {
        HTTPClient(configuration: try APIConfiguration(common.authOptions))
    }
}

struct CommonOptions: ParsableArguments {
    @OptionGroup()
    var authOptions: AuthOptions

    @Flag(default: .table, help: "Display results in specified format.")
    var outputFormat: OutputFormat
}
