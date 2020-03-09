// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation

extension APIConfiguration: Decodable {
    enum CodingKeys: String, CodingKey {
        case issuerID, privateKeyID, privateKey
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let issuerID = try values.decode(String.self, forKey: .issuerID)
        let privateKeyID = try values.decode(String.self, forKey: .privateKeyID)
        let privateKey = try values.decode(String.self, forKey: .privateKey)

        self = APIConfiguration(issuerID: issuerID, privateKeyID: privateKeyID, privateKey: privateKey)
    }
}
