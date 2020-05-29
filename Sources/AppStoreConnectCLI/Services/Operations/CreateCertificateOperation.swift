// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.Certificate

struct CreateCertificateOperation: APIOperation {

    struct Options {
        let certificateType: CertificateType
        let csrContent: String
    }

    private let endpoint: APIEndpoint<CertificateResponse>

    init(options: Options) {
        endpoint = APIEndpoint.create(
            certificateWithCertificateType: options.certificateType,
            csrContent: options.csrContent
        )
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Certificate, Error> {
        requestor
            .request(endpoint)
            .map { Certificate($0.data) }
            .eraseToAnyPublisher()
    }

}
