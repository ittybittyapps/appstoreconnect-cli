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
        response: { _ in Future({ $0(.success(response)) }) }
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

    static let response = """
    {
      "data" : {
        "type" : "certificates",
        "id" : "1234ABCD",
        "attributes" : {
          "serialNumber" : "6E06FFECD4B8D8C8",
          "certificateContent" : "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ",
          "displayName" : "Hello",
          "name" : "Mac Installer Distribution: Hello",
          "csrContent" : null,
          "platform" : "MAC_OS",
          "expirationDate" : "2021-04-22T08:02:15.000+0000",
          "certificateType" : "MAC_INSTALLER_DISTRIBUTION"
        },
        "links" : {
          "self" : "https://api.appstoreconnect.apple.com/v1/certificates/1234ABCD"
        }
      },
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/certificates"
      }
    }
    """
    .data(using: .utf8)
    .map({ try! jsonDecoder.decode(CertificateResponse.self, from: $0) })!
}
