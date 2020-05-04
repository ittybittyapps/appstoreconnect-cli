// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import Files

struct ReadCertificateCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
    commandName: "read",
    abstract: "Get information about a certificate and download the certificate data.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The certificate’s serial number. (eg. 1A23BCDEF4G5D6C7)")
    var serial: String

    @Option(help: "The file download path and name. (eg. ./file.cer)")
    var certificateOutput: String?

    func run() throws {
        let service = try makeService()

        let certificate = try service
            .readCertificate(serial: serial)

        if let certificateOutput = certificateOutput {
            guard
                let content = certificate.content,
                let data = Data(base64Encoded: content)
            else {
                throw CertificatesError.noContent
            }

            let standardizedPath = certificateOutput as NSString

            let file = try Folder(path: standardizedPath.deletingLastPathComponent)
                .createFile(
                    named: standardizedPath.lastPathComponent,
                    contents: data
                )

            print("📥 Certificate '\(certificate.name ?? "")' downloaded to: \(file.path)")
        }

        certificate.render(format: common.outputFormat)
    }
}
