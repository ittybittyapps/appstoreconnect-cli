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
        HTTPClient(configuration: APIConfiguration.load(from: common.authOptions))
    }
}

struct AuthOptions: ParsableArguments {
    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String?

    @Option(help: "Your issuer ID from the API Keys page in App Store Connect (Ex: 12345678-90ab-cdef-0987-654321abcdef)")
    var issuerId: String?

    @Option(help: "Your private key ID from App Store Connect (Ex: ABCDEF0123)")
    var privateKeyID: String?

    @Option(help: "Your private key from App Store Connect")
    var privateKey: String?

    @Option(help: "Your private API key file(.p8) path downloaded from App Store Connect")
    var privateKeyFilePath: String?
}

struct CommonOptions: ParsableArguments {
    @OptionGroup()
    var authOptions: AuthOptions

    @Flag(default: .table, help: "Display results in specified format.")
    var outputFormat: OutputFormat
}
