// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Files
import Model

public struct CertificateProcessor: ResourceWriter {

    let path: ResourcePath

    public init(path: ResourcePath) {
        self.path = path
    }

    @discardableResult
    public func write(_ certificate: Certificate) throws -> File {
        try writeFile(certificate)
    }

    @discardableResult
    public func write(_ certificates: [Certificate]) throws -> [File] {
        try certificates.map { try write($0) }
    }

}

extension Certificate: FileProvider {
    private enum Error: LocalizedError {
        case noContent

        var errorDescription: String? {
            switch self {
            case .noContent:
                return "The certificate in the response doesn't have a proper content."
            }
        }
    }

    func fileContent() throws -> Data {
        guard
            let content = content,
            let data = Data(base64Encoded: content)
            else {
                throw Error.noContent
        }

        return data
    }

    var fileName: String {
        "\(serialNumber ?? "serial").cer"
    }
}
