// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct CertificatesCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "certificates",
        abstract: "Create, download, and revoke signing certificates for app development and distribution.",
        subcommands: [
            CreateCertificateCommand.self,
            ListCertificatesCommand.self,
            ReadCertificateCommand.self,
            RevokeCertificatesCommand.self,
        ],
        defaultSubcommand: ListCertificatesCommand.self
    )
}
