// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ListCertificateOperationsTests: XCTestCase {

    typealias OperationError = ListCertificatesOperation.Error

    let noCertificatesRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(noCertificatesResponse)) }) }
    )

    func testCouldNotFindCertificate() {
        let options = ListCertificatesOperation.Options(
            filterSerial: nil,
            sort: nil,
            filterType: nil,
            filterDisplayName: nil,
            limit: nil
        )

        let operation = ListCertificatesOperation(options: options)

        let result = Result {
            try operation.execute(with: noCertificatesRequestor).await()
        }

        switch result {
        case .failure(OperationError.couldNotFindCertificate):
            break
        default:
            XCTFail("Expected failed with \(OperationError.couldNotFindCertificate), got: \(result)")
        }
    }

    static let noCertificatesResponse = Certificate
        .noCertificateResponse
        .map({ try! jsonDecoder.decode(CertificatesResponse.self, from: $0) })!
}
