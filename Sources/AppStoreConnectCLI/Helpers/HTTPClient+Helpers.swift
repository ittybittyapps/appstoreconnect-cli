// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Yams

extension HTTPClient {
    convenience init(auth: String) throws {
        let authYml = try String(contentsOfFile: auth)
        let configuration: APIConfiguration = try YAMLDecoder().decode(from: authYml)
        self.init(configuration: configuration)
    }
}
