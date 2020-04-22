// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateCertificateOperation: APIOperation {

    struct CreateCertificateDependencies {
        let certificateResponse: (APIEndpoint<CertificateResponse>) -> Future<CertificateResponse, Error>
    }

    private let endpoint: APIEndpoint<CertificateResponse>

    init(options: CreateCertificateOptions) {
        endpoint = APIEndpoint.create(
            certificateWithCertificateType: options.certificateType,
            csrContent: options.csrContent
        )
    }

    func execute(with dependencies: CreateCertificateDependencies) -> AnyPublisher<Certificate, Error> {
        dependencies
            .certificateResponse(endpoint)
            .map { Certificate($0.data) }
            .eraseToAnyPublisher()
    }

}
