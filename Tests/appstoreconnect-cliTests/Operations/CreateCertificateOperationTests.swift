// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import Bagbutik
import Combine
import Foundation
import XCTest

final class CreateCertificateOperationTests: XCTestCase {
    let options = CreateCertificateOperation.Options(
        certificateType: .iOSDevelopment,
        csrContent: "")
    
    func testExecute_success() async throws {
        let jwt = try JWT(keyId: "", issuerId: "", privateKey: "")
        let mockService = BagbutikService(jwt: jwt, fetchData: { _, _ in
            return (try Fixture(named: "v1/certificates/created_success").data, URLResponse())
        })
        
        let operation = CreateCertificateOperation(service: mockService, options: options)
        let certificate = try await operation.execute()
        
        XCTAssertEqual(certificate.attributes?.name, "Mac Installer Distribution: Hello")
        XCTAssertEqual(certificate.attributes?.platform, BundleIdPlatform.macOS)
        XCTAssertEqual(certificate.attributes?.certificateContent, "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ")
    }

//    func testExecute_propagatesUpstreamErrors() {
//        let requestor = FailureTestRequestor()
//
//        let operation = CreateCertificateOperation(options: options)
//
//        let result = Result {
//            try operation.execute(with: requestor).await()
//        }
//
//        let expectedError = TestError.somethingBadHappened
//
//        switch result {
//        case .failure(let error as TestError):
//            XCTAssertEqual(expectedError, error)
//        default:
//            XCTFail("Expected failure with: \(expectedError), got: \(result)")
//        }
//    }
}
