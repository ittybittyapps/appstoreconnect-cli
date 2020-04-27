// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ReadCertificateOperationTests: XCTestCase {

    typealias Dependencies = ReadCertificateOperation.Dependencies
    typealias OperationError = ReadCertificateOperation.ReadCertificateError

    let options = ReadCertificateOptions(serial: "abcde")

    func testExecute_success() {
        let dependencies: Dependencies = .readSuccess

        let operation = ReadCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        switch result {
        case .success(let certificate):
            XCTAssertEqual(certificate.name, "Mac Installer Distribution: Hello")
            XCTAssertEqual(certificate.platform, BundleIdPlatform.macOS)
            XCTAssertEqual(certificate.content, "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ")
        default:
            XCTFail("Error happened when parsing read certificate response")
        }
    }

    func testExecute_propagatesUpstreamErrors() {
        let dependencies: Dependencies = .readFailed

        let options = ReadCertificateOptions(serial: "")
        let operation = ReadCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        let expectedError = TestError.somethingBadHappened

        switch result {
        case .failure(let error as TestError):
            XCTAssertEqual(expectedError, error)
        default:
            XCTFail("Expected failure with: \(expectedError), got: \(result)")
        }
    }

    func testCouldNotFindCertificateError() {
        let dependencies: Dependencies = .noCertificate
        let options = ReadCertificateOptions(serial: "abcd")
        let operation = ReadCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        let expectedError = OperationError.couldNotFindCertificate("abcd")

        switch result {
        case .failure(let error as OperationError):
            XCTAssertEqual(error.errorDescription, expectedError.errorDescription)
        default:
            XCTFail("Expected failed with \(expectedError), got: \(result)")
        }
    }

    func testCertificateSerialNotUniqueError() {
        let dependencies: Dependencies = .notUnique
        let options = ReadCertificateOptions(serial: "abcd")
        let operation = ReadCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        let expectedError = OperationError.serialNumberNotUnique("abcd")

        switch result {
        case .failure(let error as OperationError):
            XCTAssertEqual(error.errorDescription, expectedError.errorDescription)
        default:
            XCTFail("Expected failed with \(expectedError), got: \(result)")
        }
    }
}

extension ReadCertificateOperationTests.Dependencies {

    typealias Dependencies = ListCertificateOperationsTests.Dependencies

    static let readSuccess = Self(
        certificatesResponse: { _ in
            Future<CertificatesResponse, Error> { promise in
                let certificateResponse = try! jsonDecoder
                    .decode(
                        CertificatesResponse.self,
                        from: Certificate.readCertificateResponse
                    )

                promise(.success(certificateResponse))
            }
        }
    )

    static let readFailed = Self(
        certificatesResponse: { _ in
            Future<CertificatesResponse, Error> { promise in
                promise(.failure(TestError.somethingBadHappened))
            }
        }
    )

    static let noCertificate = Self(
        certificatesResponse: { _ in
            Future<CertificatesResponse, Error> { promise in
                let certificatesResponse = try! jsonDecoder
                    .decode(
                        CertificatesResponse.self,
                        from: Certificate.noCertificateResponse
                    )

                promise(.success(certificatesResponse))
            }
        }
    )

    static let notUnique = Self(
        certificatesResponse: { _ in
            Future<CertificatesResponse, Error> { promise in
                let certificatesResponse = try! jsonDecoder
                    .decode(
                        CertificatesResponse.self,
                        from: Certificate.readCertificateNotUniqueResponse
                    )

                promise(.success(certificatesResponse))
            }
        }
    )
}
