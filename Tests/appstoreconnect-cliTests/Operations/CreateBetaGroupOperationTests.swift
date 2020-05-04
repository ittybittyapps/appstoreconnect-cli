// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
@testable import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class CreateBetaGroupOperationTests: XCTestCase {
    typealias Operation = CreateBetaGroupOperation
    typealias Options = Operation.Options

    let successRequestor = OneEndpointTestRequestor(
        response: { _ in
            Future { $0(.success(betaGroupResponse)) }
        }
    )

    func testExecute_success() throws {
        let app = Self.appsResponse.data.first!

        let options = Options(
            app: app,
            groupName: "test-group",
            publicLinkEnabled: false,
            publicLinkLimit: nil
        )

        let output = try Operation(options: options).execute(with: successRequestor).await()

        XCTAssertEqual(output.app.id, app.id)
        XCTAssertEqual(output.betaGroup.id, "12345678-90ab-cdef-1234-567890abcdef")
    }

    func testExecute_propagatesUpstreamErrors() {
        let options = Options(
            app: Self.appsResponse.data.first!,
            groupName: "test-group",
            publicLinkEnabled: false,
            publicLinkLimit: nil
        )

        let operation = Operation(options: options)

        let result = Result { try operation.execute(with: FailureTestRequestor()).await() }

        switch result {
        case .failure(TestError.somethingBadHappened):
            break
        default:
            XCTFail("Expected TestError.somethingBadHappened, got: \(result)")
        }
    }

    func testExecute_populatesEndpointBody() {
        let options = Options(
            app: Self.appsResponse.data.first!,
            groupName: "test-group",
            publicLinkEnabled: true,
            publicLinkLimit: 10
        )

        var betaGroupEndpoint: APIEndpoint<BetaGroupResponse>?

        let dependencies = OneEndpointTestRequestor(
            response: { endpoint -> Future<BetaGroupResponse, Error> in
                betaGroupEndpoint = endpoint
                return Future { $0(.failure(TestError.somethingBadHappened)) }
            }
        )

        _ = try? Operation(options: options).execute(with: dependencies).await()

        let bodyJSON = (betaGroupEndpoint?.body)
            .flatMap({ try? JSONSerialization.jsonObject(with: $0, options: []) }) as? [String: Any]

        guard
            let data = bodyJSON?["data"] as? [String: Any],
            let attributes = data["attributes"] as? [String: Any],
            let relationships = data["relationships"] as? [String: [String: Any]],
            let appData = relationships["app"]?["data"] as? [String: Any]
        else {
            XCTFail(); return
        }

        XCTAssertEqual(appData["id"] as? String, "0123456789")
        XCTAssertEqual(attributes["name"] as? String, "test-group")
        XCTAssertEqual(attributes["publicLinkLimitEnabled"] as? Bool, true)
        XCTAssertEqual(attributes["publicLinkEnabled"] as? Bool, true)
        XCTAssertEqual(attributes["publicLinkLimit"] as? Int, 10)
    }

    static let appsResponse = """
        {
            "data": [
                {
                    "type": "apps",
                    "id": "0123456789",
                    "attributes": {
                        "name": "Test App",
                        "bundleId": "com.example.test",
                        "sku": "TEST1",
                        "primaryLocale": "en-AU"
                    },
                    "links": {
                        "self": "https://api.appstoreconnect.apple.com/v1/apps/0123456789"
                    }
                }
            ],
            "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps?filter%5BbundleId%5D=com.example.test"
            }
        }
        """
        .data(using: .utf8)
        .map({ try! jsonDecoder.decode(AppsResponse.self, from: $0) })!

    static let betaGroupResponse = """
        {
            "data": {
                "type": "betaGroups",
                "id": "12345678-90ab-cdef-1234-567890abcdef",
                "attributes": {
                    "name": "test-group",
                    "createdDate": "2020-04-24T05:40:26.0Z",
                    "isInternalGroup": false,
                    "publicLinkEnabled": false,
                    "publicLinkId": null,
                    "publicLinkLimitEnabled": false,
                    "publicLinkLimit": null,
                    "publicLink": null,
                    "feedbackEnabled": true
                },
                "links": {
                    "self": "https://api.appstoreconnect.apple.com/v1/betaGroups/12345678-90ab-cdef-1234-567890abcdef"
                }
            },
            "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/betaGroups"
            }
        }
        """
        .data(using: .utf8)
        .map({ try! jsonDecoder.decode(BetaGroupResponse.self, from: $0) })!
}
