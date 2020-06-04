// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Files
import Model

public struct ProfileProcessor: ResourceWriter {

    public static let profileExtension = "mobileprovision"

    let path: ResourcePath

    public init(path: ResourcePath) {
        self.path = path
    }

    @discardableResult
    public func write(_ certificate: Profile) throws -> File {
        try writeFile(certificate)
    }

    @discardableResult
    public func write(_ certificates: [Profile]) throws -> [File] {
        try certificates.map { try write($0) }
    }

}

extension Profile: FileProvider {
    private enum Error: LocalizedError {
        case noContent

        var errorDescription: String? {
            switch self {
            case .noContent:
                return "The Profile in the response doesn't have a proper content."
            }
        }
    }

    func fileContent() throws -> Data {
        guard
            let content = profileContent,
            let data = Data(base64Encoded: content) else {
                throw Error.noContent
            }

        return data
    }

    var fileName: String {
        "\(uuid!).\(ProfileProcessor.profileExtension)"
    }
}
