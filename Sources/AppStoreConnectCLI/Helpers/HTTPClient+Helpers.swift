// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Yams

extension HTTPClient {
    convenience init(authenticationYmlPath: String) throws {
        let authYml = try String(contentsOfFile: authenticationYmlPath)
        let configuration: APIConfiguration = try YAMLDecoder().decode(from: authYml)
        self.init(configuration: configuration)
    }

    convenience init(authOptions: AuthOptions) throws {
        // First use variables from command line
        if let issuerId = authOptions.issuerId,
            let privateKeyID = authOptions.privateKeyID,
            let privateKey = authOptions.privateKey {

            let configuration = APIConfiguration(
                issuerID: issuerId,
                privateKeyID: privateKeyID,
                privateKey: privateKey)

            self.init(configuration: configuration)

            return
        }

        // Then use config file
        if let authFilePath = authOptions.auth,
            let authYml = try? String(contentsOfFile: authFilePath),
            let configuration: APIConfiguration = try? YAMLDecoder().decode(from: authYml) {

            self.init(configuration: configuration)

            return
        }

        // Last, try to use environment variables
        if let issuerId = ProcessInfo.processInfo.environment["APPSTORE_ISSUER_ID"],
            let privateKeyID = ProcessInfo.processInfo.environment["APPSTORE_KEY_ID"],
            let privateKey = ProcessInfo.processInfo.environment["APPSTORE_KEY"] {

            let configuration = APIConfiguration(
                issuerID: issuerId,
                privateKeyID: privateKeyID,
                privateKey: privateKey)

            self.init(configuration: configuration)

            return
        }

        fatalError("Can't init APIConfiguration, no auth config found")
    }
}
