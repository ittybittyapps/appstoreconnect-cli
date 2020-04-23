// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListCertificatesOpertaion: APIOperation {

    struct ListCertificatesDependencies {
        let certificatesResponse: (APIEndpoint<CertificatesResponse>) -> Future<CertificatesResponse, Error>
    }

    enum ListCertificatesError: LocalizedError {
        case couldNotCertificate

        var failureReason: String? {
            switch self {
            case .couldNotCertificate:
                return "Couldn't find certificate with input filters"
            }
        }
    }

    private let endpoint: APIEndpoint<CertificatesResponse>

    init(options: ListCertificatesOptions) {
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

    func execute(with dependencies: ListCertificatesDependencies) -> AnyPublisher<[Certificate], Error> {
        dependencies
            .certificatesResponse(endpoint)
            .tryMap { (response: CertificatesResponse) -> [Certificate] in
                guard !response.data.isEmpty else {
                    throw ListCertificatesError.couldNotCertificate
                }

                return response.data.map(Certificate.init)
            }
            .eraseToAnyPublisher()
    }

}
