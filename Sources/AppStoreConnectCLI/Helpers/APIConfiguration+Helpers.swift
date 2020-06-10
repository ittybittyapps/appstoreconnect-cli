// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Yams

extension APIConfiguration {
    init(_ authOptions: AuthOptions) throws {

        guard authOptions.apiIssuer.value.isEmpty == false else {
            throw AuthOptions.Error.issuerNotProvided
        }

        guard authOptions.apiKeyId.value.isEmpty == false else {
            throw AuthOptions.Error.apiKeyIdNotProvided
        }

        self.init(
            issuerID: authOptions.apiIssuer.value,
            privateKeyID: authOptions.apiKeyId.value,
            privateKey: try authOptions.apiKeyId.load()
        )
    }
}
