// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.Certificate

struct ListCertificatesOperation: APIOperation {

    enum ListCertificatesError: LocalizedError {
        case couldNotFindCertificate

        var errorDescription: String? {
            switch self {
            case .couldNotFindCertificate:
                return "Couldn't find certificate with input filters"
            }
        }
    }

    struct Options {
        let filterSerial: String?
        let sort: Certificates.Sort?
        let filterType: CertificateType?
        let filterDisplayName: String?
        let limit: Int?
    }

    private let endpoint: APIEndpoint<CertificatesResponse>

    init(options: Options) {
        typealias Filter = Certificates.Filter

        var filters = [Certificates.Filter]()

        if let filterSerial = options.filterSerial {
            filters.append(.serialNumber([filterSerial]))
        }

        if let filterType = options.filterType {
            filters.append(.certificateType(filterType))
        }

        if let filterDisplayName = options.filterDisplayName {
            filters.append(.displayName([filterDisplayName]))
        }

        endpoint = APIEndpoint.listDownloadCertificates(
            filter: filters,
            sort: [options.sort].compactMap { $0 },
            limit: options.limit
        )
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[Certificate], Error> {
        requestor.request(endpoint)
            .tryMap { (response: CertificatesResponse) -> [Certificate] in
                guard !response.data.isEmpty else {
                    throw ListCertificatesError.couldNotFindCertificate
                }

                return response.data.map(Certificate.init)
            }
            .eraseToAnyPublisher()
    }

}
