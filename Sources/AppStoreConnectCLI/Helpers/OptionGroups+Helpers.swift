// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import ArgumentParser

struct AuthOptions: ParsableArguments {
    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String?

    @Option(help: "Your issuer ID from the API Keys page in App Store Connect (Ex: 57246542-96fe-1a63-e053-0824d011072a)")
    var issuerId: String?

    @Option(help: "Your private key ID from App Store Connect (Ex: 2X9R4HXF34)")
    var privateKeyID: String?

    @Option(help: "Your private key from App Store Connect")
    var privateKey: String?
}

struct OutputOptions: ParsableArguments {
    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?
}


