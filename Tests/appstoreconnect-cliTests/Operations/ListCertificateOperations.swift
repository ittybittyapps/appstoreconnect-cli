// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ListCertificateOperationsTests: XCTestCase {

    typealias OperationError = ListCertificatesOperation.Error

    let noCertificatesRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(Certificate.noCertificateResponse)) }) }
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
}
