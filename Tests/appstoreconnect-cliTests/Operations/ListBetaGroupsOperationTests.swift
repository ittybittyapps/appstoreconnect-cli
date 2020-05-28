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

    static let response: BetaGroupsResponse = """
    {
        "data": [
            {
                "type": "betaGroups",
                "id": "12345678-90ab-cdef-1234-567890abcdef",
                "attributes": {
                    "name": "Example Group 1",
                    "createdDate": "2020-04-08T07:40:14.179Z",
                    "isInternalGroup": true,
                    "publicLinkEnabled": null,
                    "publicLinkId": null,
                    "publicLinkLimitEnabled": null,
                    "publicLinkLimit": null,
                    "publicLink": null,
                    "feedbackEnabled": true
                },
                "relationships": {
                    "app": {
                        "data": {
                            "type": "apps",
                            "id": "1234567890"
                        },
                        "links": {
                            "self": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef/relationships/app",
                            "related": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef/app"
                        }
                    }
                },
                "links": {
                    "self": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef"
                }
            }
        ],
        "included": [
            {
                "type": "apps",
                "id": "1234567890",
                "attributes": {
                    "name": "Test App",
                    "bundleId": "com.example.test",
                    "sku": "TEST1",
                    "primaryLocale": "en-AU"
                },
                "links": {
                    "self": "https://api.appstoreconnect.apple.com/v1/apps/1234567890"
                }
            }
        ],
        "links": {
            "self": "https://api.appstoreconnect.apple.com/v1/betaGroups?include=app"
        }
    }
    """
    .data(using: .utf8)
    .map({ try! jsonDecoder.decode(BetaGroupsResponse.self, from: $0) })!
}
