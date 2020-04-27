// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadCertificateOperation: APIOperation {

    struct ReadCertificateDependencies {
        let certificatesResponse: (APIEndpoint<CertificatesResponse>) -> Future<CertificatesResponse, Error>
    }

    enum ReadCertificateError: LocalizedError {
        case couldNotFindCertificate(String)
        case serialNumberNotUnique(String)

        var errorDescription: String? {
            switch self {
            case .couldNotFindCertificate(let serial):
                return "Couldn't find certificate with input '\(serial)'"
            case .serialNumberNotUnique(let serial):
                return "The serial number your input '\(serial)' is not unique"
            }
        }
    }

    private let endpoint: APIEndpoint<CertificatesResponse>

    private let serial: String

    init(options: ReadCertificateOptions) {
        endpoint = APIEndpoint.listDownloadCertificates(
            filter: [.serialNumber([options.serial])]
        )

        serial = options.serial
    }

    func execute(with dependencies: ReadCertificateDependencies) -> AnyPublisher<Certificate, Error> {
        dependencies
            .certificatesResponse(endpoint)
            .tryMap { [serial] (response: CertificatesResponse) -> Certificate in
                switch response.data.count {
                case 0:
                    throw ReadCertificateError.couldNotFindCertificate(serial)
                case 1:
                    return Certificate(response.data.first!)
                default:
                    throw ReadCertificateError.serialNumberNotUnique(serial)
                }
            }
            .eraseToAnyPublisher()
    }

}
