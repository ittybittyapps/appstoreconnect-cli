// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadCertificateOperation: APIOperation {

    struct Options {
        let serial: String
    }

    enum ReadCertificateError: LocalizedError {
        case couldNotFindCertificate(String)
        case serialNumberNotUnique(String)

        var errorDescription: String? {
            switch self {
            case .couldNotFindCertificate(let serial):
                return "Couldn't find certificate with serial '\(serial)'."
            case .serialNumberNotUnique(let serial):
                return "The serial number your provided '\(serial)' is not unique."
            }
        }
    }

    private var endpoint: APIEndpoint<CertificatesResponse> {
        APIEndpoint.listDownloadCertificates(
            filter: [.serialNumber([options.serial])]
        )
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Certificate, Error> {
        requestor.request(endpoint)
            .tryMap { [serial = options.serial] (response: CertificatesResponse) -> Certificate in
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
