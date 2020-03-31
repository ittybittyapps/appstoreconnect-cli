// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Yams

extension APIConfiguration {
    static func load(from authOptions: AuthOptions) -> APIConfiguration {
        // First use variables from command line
        if let issuerId = authOptions.issuerId,
            let privateKeyID = authOptions.privateKeyID {

            if let privateKey = authOptions.privateKey {
                return APIConfiguration(issuerId, privateKeyID, privateKey)
            }

            if let path = authOptions.privateKeyFilePath {
                return APIConfiguration(issuerId, privateKeyID, readPrivateKeyFrom(filePath: path))
            }
        }

        // Then use config file
        if let authFilePath = authOptions.auth,
            let authYml = try? String(contentsOfFile: authFilePath),
            let configuration: APIConfiguration = try? YAMLDecoder().decode(from: authYml) {

            return configuration
        }

        // Last, try to use environment variables
        if let issuerId = ProcessInfo.appstoreIssuerId,
            let privateKeyID = ProcessInfo.appstorePrivateKeyID {

            if let privateKey = ProcessInfo.appstorePrivateKey {
                return APIConfiguration(issuerId, privateKeyID, privateKey)
            }

            if let path = ProcessInfo.appstoreKeyFilePath {
                return APIConfiguration(issuerId, privateKeyID, readPrivateKeyFrom(filePath: path))
            }
        }

        fatalError("Can't load APIConfiguration, no auth config found")
    }

    static func readPrivateKeyFrom(filePath: String) -> String {
        let apiKeyFileContent = try? String(contentsOfFile: filePath, encoding: .utf8)
        let fileContentArray = apiKeyFileContent?.components(separatedBy: .newlines)

        // Strip header and footer, then concatenate each line together
        guard let privateKey = fileContentArray?.filter({ !$0.contains("-----") }).joined() else {
            fatalError("Invalid private key file path provided, or file has invalid content")
        }

        return privateKey
    }

    init(_ issuerID: String, _ privateKeyID: String, _ privateKey: String) {
        self.init(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey)
    }
}

private extension ProcessInfo {
    static var appstoreIssuerId: String? {
        self.processInfo.environment["APPSTORE_ISSUER_ID"]
    }

    static var appstorePrivateKeyID: String? {
        self.processInfo.environment["APPSTORE_KEY_ID"]
    }

    static var appstorePrivateKey: String? {
        self.processInfo.environment["APPSTORE_KEY"]
    }

    static var appstoreKeyFilePath: String? {
        self.processInfo.environment["APPSTORE_KEY_FILE_PATH"]
    }
}
