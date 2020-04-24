// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class CreateCertificateOperationTests: XCTestCase {
    typealias Dependencies = CreateCertificateOperation.Dependencies

    func testCreateCertificate_success() {
        let dependencies: Dependencies = .createdSuccess

        let options = CreateCertificateOptions(
            certificateType: .iOSDevelopment,
            csrContent: "")

        let operation = CreateCertificateOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        switch result {
            case .success(let certificate):
                XCTAssertEqual(certificate.name, "Mac Installer Distribution: Hello")
                XCTAssertEqual(certificate.platform, BundleIdPlatform.macOS)
                XCTAssertEqual(certificate.content, "MIIFpDCCBIygAwIBAgIIbgb/7NS42MgwDQ")
            default:
                XCTFail("Error happened when parsing create certificate response")
        }
    }
}

private extension CreateCertificateOperationTests.Dependencies {
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        return jsonDecoder
    }()

    static let createdSuccessResponse = """
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
    """.data(using: .utf8)!

    static let createdSuccess = Self(
        certificateResponse: { _ in
            Future<CertificateResponse, Error> { promise in
                let certificateResponse = try! jsonDecoder
                    .decode(CertificateResponse.self, from: createdSuccessResponse)
                promise(.success(certificateResponse))
            }
        }
    )
}
