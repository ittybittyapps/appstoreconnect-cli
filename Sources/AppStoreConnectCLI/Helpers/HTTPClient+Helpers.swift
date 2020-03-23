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
}
