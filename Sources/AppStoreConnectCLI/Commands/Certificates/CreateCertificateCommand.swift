// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct CreateCertificateCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new certificate")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The type of certificate. (eg. IOS_DEVELOPMENT)")
    var certificateType: String

    @Option(help: "The file path of your CSR file. (eg. folder/CertificateSigningRequest.certSigningRequest)")
    var csrFile: String

    enum CommandError: LocalizedError {
        case invalidCertificateType(String)
        case invalidCSRFilePath(String)

        var errorDescription: String? {
            switch self {
            case .invalidCertificateType(let type):
                return "\(type) is not a valid certificate type"
            case .invalidCSRFilePath(let path):
                return "\(path) is not a valid CSR file path"
            }
        }
    }

    func run() throws {
        let api = try makeService()

        let type = try getCertificateType(matching: certificateType)

        let csrContent = try readCSRContent(from: csrFile)

        let endpoint = APIEndpoint.create(
            certificateWithCertificateType: type,
            csrContent: csrContent
        )

        _ = api
            .request(endpoint)
            .map { Certificate($0.data) }
            .renderResult(format: common.outputFormat)
    }

    func getCertificateType(matching type: String) throws -> CertificateType {
        guard let type = CertificateType(rawValue: certificateType) else {
            throw CommandError.invalidCertificateType(certificateType)
        }

        return type
    }

    func readCSRContent(from filePath: String) throws -> String {
        do {
            return try String(contentsOfFile: csrFile, encoding: .utf8)
        } catch {
            throw CommandError.invalidCSRFilePath(csrFile)
        }
    }
}
