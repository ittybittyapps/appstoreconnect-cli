// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Yams

extension APIConfiguration {
    static func load(from authOptions: AuthOptions) -> APIConfiguration {
        // First use variables from command line
        if let issuerId = authOptions.issuerId,
            let privateKeyID = authOptions.privateKeyID,
            let privateKey = authOptions.privateKey {

            return APIConfiguration(
                issuerID: issuerId,
                privateKeyID: privateKeyID,
                privateKey: privateKey)
        }

        // Then use config file
        if let authFilePath = authOptions.auth,
            let authYml = try? String(contentsOfFile: authFilePath),
            let configuration: APIConfiguration = try? YAMLDecoder().decode(from: authYml) {

            return configuration
        }

        // Last, try to use environment variables
        if let issuerId = ProcessInfo.processInfo.environment["APPSTORE_ISSUER_ID"],
            let privateKeyID = ProcessInfo.processInfo.environment["APPSTORE_KEY_ID"],
            let privateKey = ProcessInfo.processInfo.environment["APPSTORE_KEY"] {

            return APIConfiguration(
                issuerID: issuerId,
                privateKeyID: privateKeyID,
                privateKey: privateKey)
        }

        fatalError("Can't load APIConfiguration, no auth config found")
    }
}
