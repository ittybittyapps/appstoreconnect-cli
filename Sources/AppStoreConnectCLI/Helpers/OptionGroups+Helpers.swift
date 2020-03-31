// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import ArgumentParser

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


