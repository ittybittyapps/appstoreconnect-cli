// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

struct APIKeyID: EnvironmentLoadableArgument {

    enum Error: Swift.Error {
        case apiKeyNotFound
    }

    static let apiKeyEnvironmentKey = "APPSTORE_CONNECT_API_KEY"
    static let searchPaths = ["./private_keys", "~/private_keys", "~/.private_keys", "~/.appstoreconnect/private_keys"]

    var argument: String

    init?(argument: String) {
        self.argument = argument
    }

    private func findKeyFileURL() -> URL? {
        let fileManager = FileManager()
        let homeDirectoryPath = fileManager.homeDirectoryForCurrentUser.path
        let authKeyFilename = "AuthKey_\(value).p8"

        let fullyQualifiedURLs = Self.searchPaths.lazy.map { path -> URL in
            let expandedPath = path.replacingOccurrences(of: "~", with: homeDirectoryPath)
            return URL(fileURLWithPath: expandedPath).appendingPathComponent(authKeyFilename)
        }

        return fullyQualifiedURLs.first { fileManager.fileExists(atPath: $0.path) }
    }

    func load() throws -> String {
        return loadPEM()
            .components(separatedBy: .newlines)
            .filter { $0.hasSuffix("PRIVATE KEY-----") == false }
            .joined()
    }
    
    func loadPEM() throws -> String {

        // TODO: validate the format of the env var content
        // TODO: validate format of file is correct (if found)

        guard let apiKeyFileContent =
            try (ProcessInfo.processInfo.environment["APPSTORE_CONNECT_API_KEY"] ??
                findKeyFileURL().map { try String(contentsOf: $0, encoding: .utf8) })
        else {
            throw Error.apiKeyNotFound
        }

        return apiKeyFileContent
    }
}
