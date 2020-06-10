// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ExpireBuildOperation: APIOperation {

    struct Options {
        let buildId: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Void, Error> {

        let buildModifyEndpoint = APIEndpoint.modify(
            buildWithId: self.options.buildId,
            appEncryptionDeclarationId: "",
            expired: true,
            usesNonExemptEncryption: nil)

        return requestor.request(buildModifyEndpoint)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
