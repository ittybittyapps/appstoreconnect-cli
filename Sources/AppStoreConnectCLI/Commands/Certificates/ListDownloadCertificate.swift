// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct ListDownloadCertificate: CommonParsableCommand {
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

    enum CommandError: LocalizedError {
        case invalidPath(String)
        case invalidContent
        case notFound

        var errorDescription: String? {
            switch self {
            case .invalidPath(let path):
                return "Download failed, please check the path \(path) you input and try again"
            case .invalidContent:
                return "The certificate in the response doesn't have a proper content"
            case .notFound:
                return "Unable to find certificate with input filters."
            }
        }
    }

    func run() throws {
        let api = try makeService()

        var filters = [Certificates.Filter]()

        if let filterSerial = filterSerial {
            filters.append(.serialNumber([filterSerial]))
        }

        if let filterType = filterType {
            filters.append(.certificateType(filterType))
        }

        if let filterDisplayName = filterDisplayName {
            filters.append(.displayName([filterDisplayName]))
        }

        let endpoint = APIEndpoint.listDownloadCertificates(
            filter: filters,
            sort: [sort].compactMap { $0 },
            limit: limit
        )

        _ = api
            .request(endpoint)
            .map { $0.data.map(Certificate.init) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { [common, downloadPath] (certificates: [Certificate]) in
                    guard !certificates.isEmpty else {
                        print(CommandError.notFound.errorDescription!)
                        return
                    }

                    if let downloadPath = downloadPath {
                        _ = certificates.map { (certificate: Certificate) in
                            guard let content = certificate.content else {
                                print(CommandError.invalidContent.errorDescription!)
                                return
                            }

                            let filePath = "\(downloadPath)/\(certificate.serialNumber ?? "serial").cer"
                            let result = FileManager
                                .default
                                .createFile(atPath: filePath, contents: Data(base64Encoded: content))

                            result ?
                                print("📥 Certificate '\(certificate.name ?? "")' downloaded to: \(filePath)")
                                :
                                print(CommandError.invalidPath(filePath).errorDescription!)
                        }
                    }

                    Renderers.ResultRenderer(format: common.outputFormat).render(certificates)
                }
            )
    }

}
