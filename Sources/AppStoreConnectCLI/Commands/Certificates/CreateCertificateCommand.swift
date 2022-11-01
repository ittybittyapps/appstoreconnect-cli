// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Bagbutik
import Foundation
import struct Model.Certificate

struct CreateCertificateCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new certificate using a certificate signing request.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The type of certificate to create. One of \(CertificateType.allValueStrings.formatted(.list(type: .or))).")
    var certificateType: CertificateType

    @Argument(help: "The Certificate Signing Request (CSR) file path.")
    var csrFile: String

    func run() async throws {
        
        let csrContent = try String(contentsOfFile: csrFile, encoding: .utf8)
        
        let result = Model.Certificate(
            try await CreateCertificateOperation(
                service: .init(authOptions: common.authOptions),
                options: .init(certificateType: certificateType, csrContent: csrContent)
            )
            .execute()
        )

        result.render(options: common.outputOptions)
    }
}
