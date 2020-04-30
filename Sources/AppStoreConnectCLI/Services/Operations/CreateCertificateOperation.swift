// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateCertificateOperation: APIOperation {

    private let endpoint: APIEndpoint<CertificateResponse>

    init(options: CreateCertificateOptions) {
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
