// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListCertificatesOperation: APIOperation {

    typealias Filter = Certificates.Filter

    enum Error: LocalizedError {
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

    var filters: [Filter] {
        var filters = [Filter]()

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

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[Certificate], Swift.Error> {
        let filters = self.filters
        let sort = [options.sort].compactMap { $0 }

        if let limit = options.limit {
            return requestor.request(
                .listDownloadCertificates(
                    filter: filters,
                    sort: sort,
                    limit: limit
                )
            )
            .tryMap(handleCertificateResponse)
            .eraseToAnyPublisher()
        } else {
            return requestor.requestAllPages {
                .listDownloadCertificates(
                    filter: filters,
                    sort: sort,
                    next: $0
                )
            }
            .tryMap { [handleCertificateResponse] in
                try $0.flatMap(handleCertificateResponse)
            }
            .eraseToAnyPublisher()
        }
    }

    private func handleCertificateResponse(
        _ response: CertificatesResponse
    ) throws -> [Certificate] {
        guard !response.data.isEmpty else {
            throw Error.couldNotFindCertificate
        }

        return response.data
    }

}

extension CertificatesResponse: PaginatedResponse { }
