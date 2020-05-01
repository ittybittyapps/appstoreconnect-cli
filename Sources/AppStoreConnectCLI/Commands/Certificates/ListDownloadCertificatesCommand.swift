// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import Files

struct ListDownloadCertificatesCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list certificates and download their data.")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "The certificate’s serial number. (eg. 1A23BCDEF4G5D6C7)")
    var filterSerial: String?

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(Certificates.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: Certificates.Sort?

    @Option(help: "The type of certificate to create \(CertificateType.allCases).")
    var filterType: CertificateType?

    @Option(help: "The certificate’s display name. (eg. Mac Installer Distribution: TeamName)")
    var filterDisplayName: String?

    @Option(help: "Limit the number of resources (maximum 200).")
    var limit: Int?

    @Option(help: "The file download path. (eg. ~/Documents)")
    var downloadPath: String?

    func run() throws {
        let service = try makeService()

        let options = ListCertificatesOptions(
            filterSerial: filterSerial,
            sort: sort,
            filterType: filterType,
            filterDisplayName: filterDisplayName,
            limit: limit
        )

        let certificates = try service
            .listCertificates(with: options)
            .await()

        if let downloadPath = downloadPath {
            try certificates.forEach { (certificate: Certificate) in
                guard
                    let content = certificate.content,
                    let data = Data(base64Encoded: content)
                else {
                    throw CertificatesError.noContent
                }

                let file = try Folder(path: downloadPath)
                    .createFile(
                        named: "\(certificate.serialNumber ?? "serial").cer",
                        contents: data
                    )

                print("📥 Certificate '\(certificate.name ?? "")' downloaded to: \(file.path)")
            }
        }

        certificates.render(format: common.outputFormat)
    }

}
