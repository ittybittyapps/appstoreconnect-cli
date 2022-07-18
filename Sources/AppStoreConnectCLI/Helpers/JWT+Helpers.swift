// Copyright 2022 Itty Bitty Apps Pty Ltd

import Foundation
import Bagbutik

extension JWT {
    init(_ authOptions: AuthOptions) throws {

        guard authOptions.apiIssuer.value.isEmpty == false else {
            throw AuthOptions.Error.issuerNotProvided
        }

        guard authOptions.apiKeyId.value.isEmpty == false else {
            throw AuthOptions.Error.apiKeyIdNotProvided
        }

        try self.init(
            keyId: authOptions.apiKeyId.value,
            issuerId: authOptions.apiIssuer.value,
            privateKey: try authOptions.apiKeyId.loadPEM()
        )
    }
}
