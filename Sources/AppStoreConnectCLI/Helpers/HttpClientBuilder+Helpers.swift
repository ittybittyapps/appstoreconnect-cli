// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Yams

protocol HTTPClientBuilder {
    var auth: String { get }
}

extension HTTPClientBuilder {
    func setupAPI(auth: String) throws -> HTTPClient  {
        let authYml = try String(contentsOfFile: auth)
        let configuration: APIConfiguration = try YAMLDecoder().decode(from: authYml)
        return HTTPClient(configuration: configuration)
    }
}
