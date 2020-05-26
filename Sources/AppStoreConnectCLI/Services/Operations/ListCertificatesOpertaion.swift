// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.Certificate

struct ListCertificatesOperation: APIOperation {

    typealias Filter = Certificates.Filter

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
    
    var filters: [Certificates.Filter] {
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

        return filters
    }

    let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[Certificate], Error> {
        let filters = self.filters
        let sort = [options.sort].compactMap { $0 }
        let limit = options.limit

        return requestor.requestAllPages {
            .listDownloadCertificates(
                filter: filters,
                sort: sort,
                limit: limit,
                next: $0
            )
        }
        .tryMap {
            try $0.flatMap { (response: CertificatesResponse) -> [Certificate] in
                guard !response.data.isEmpty else {
                    throw ListCertificatesError.couldNotFindCertificate
                }

                return response.data.map(Certificate.init)
            }
        }
        .eraseToAnyPublisher()
    }

}

extension CertificatesResponse: PaginatedResponse { }
