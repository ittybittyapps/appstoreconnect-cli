// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ListCertificateOperationsTests: XCTestCase {
    typealias Dependencies = ListCertificatesOperation.Dependencies
    typealias OperationError = ListCertificatesOperation.ListCertificatesError

    func testCouldNotFindCertificate() {
        let dependencies: Dependencies = .noCertificate
        let options = ListCertificatesOptions(
            filterSerial: nil,
            sort: nil,
            filterType: nil,
            filterDisplayName: nil,
            limit: nil
        )

        let expectedError = OperationError.couldNotFindCertificate

        let operation = ListCertificatesOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        switch result {
        case .failure(let error as OperationError):
            XCTAssertEqual(error.errorDescription, expectedError.errorDescription)
        default:
            XCTFail("Expected failed with \(expectedError), got: \(result)")
        }
    }
}

private extension ListCertificateOperationsTests.Dependencies {
    static let jsonDecoder = JSONDecoder()

    static let noCertificatesResponse = """
    {
      "data" : [ ],
      "links": {
        "self": "https://api.appstoreconnect.apple.com/v1/certificates"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)!

    static let noCertificate = Self(
        certificatesResponse: { _ in
            Future<CertificatesResponse, Error> { promise in
                let certificatesResponse = try! jsonDecoder.decode(
                    CertificatesResponse.self, from: noCertificatesResponse
                )

                promise(.success(certificatesResponse))
            }
        }
    )
}
