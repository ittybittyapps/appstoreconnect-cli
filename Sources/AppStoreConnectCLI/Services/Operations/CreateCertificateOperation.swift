// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation

struct CreateCertificateOperation: APIOperationV2 {

    struct Options {
        let certificateType: CertificateType
        let csrContent: String
    }

    private let service: BagbutikService
    private let options: Options

    init(service: BagbutikService, options: Options) {
        self.service = service
        self.options = options
    }
    
    func execute() async throws -> Certificate {
        let body = CertificateCreateRequest(
            data: .init(
                attributes: .init(
                    certificateType: options.certificateType,
                    csrContent: options.csrContent
                )
            )
        )
        
        return try await service.request(.createCertificateV1(requestBody: body)).data
    }

}
