// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ListBetaGroupsOperationTests: XCTestCase {
    typealias Operation = ListBetaGroupsOperation
    typealias Options = Operation.Options

    let successRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(response)) }) }
    )

    func testExecute_success() throws {
        let operation = Operation(options: Options(appIds: [], names: [], sort: nil))

        let output = try operation.execute(with: successRequestor).await()

        XCTAssertEqual(output.count, 1)
        XCTAssertEqual(output.first?.app.id, "1234567890")
        XCTAssertEqual(output.first?.betaGroup.id, "12345678-90ab-cdef-1234-567890abcdef")
    }

    func testExecute_propagatesUpstreamErrors() {
        let operation = Operation(options: Options(appIds: [], names: [], sort: nil))

        let result = Result { try operation.execute(with: FailureTestRequestor()).await() }

        switch result {
        case .failure(TestError.somethingBadHappened):
            break
        default:
            XCTFail("Expected \(TestError.somethingBadHappened), got: \(result)")
        }
    }

    static let response: BetaGroupsResponse = jsonDecoder.decodeFixture(named: "v1/betagroups/list_betagroup")

}
