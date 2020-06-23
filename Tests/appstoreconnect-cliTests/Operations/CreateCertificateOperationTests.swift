// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class CreateCertificateOperationTests: XCTestCase {
    let options = CreateCertificateOperation.Options(
        certificateType: .iOSDevelopment,
        csrContent: "")

    let successRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(Certificate.createCertificateResponse)) }) }
    )

    func testExecute_success() {
        let operation = CreateCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: successRequestor).await()
        }

        switch result {
        case .success(let certificate):
            XCTAssertEqual(certificate.name, "Mac Installer Distribution: Hello")
            XCTAssertEqual(certificate.platform, BundleIdPlatform.macOS.rawValue)
            XCTAssertEqual(certificate.content, "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ")
        default:
            XCTFail("Error happened when parsing create certificate response")
        }
    }

    func testExecute_propagatesUpstreamErrors() {
        let requestor = FailureTestRequestor()

        let operation = CreateCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: requestor).await()
        }

        let expectedError = TestError.somethingBadHappened

        switch result {
        case .failure(let error as TestError):
            XCTAssertEqual(expectedError, error)
        default:
            XCTFail("Expected failure with: \(expectedError), got: \(result)")
        }
    }
}
