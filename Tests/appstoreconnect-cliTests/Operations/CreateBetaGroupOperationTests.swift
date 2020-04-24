// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
@testable import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class CreateBetaGroupOperationTests: XCTestCase {
    typealias Operation = CreateBetaGroupOperation
    typealias Dependencies = Operation.Dependencies
    typealias Options = Operation.Options

    func testExecute_success() {
        let operation = Operation(
            options: .init(
                appBundleId: "com.example.test",
                groupName: "test-group",
                publicLinkEnabled: false,
                publicLinkLimit: nil
            )
        )

        let expectedGroup = BetaGroup(
            appBundleId: "com.example.test",
            appName: "Test App",
            groupName: "test-group",
            isInternal: false,
            publicLink: nil,
            publicLinkEnabled: false,
            publicLinkLimit: nil,
            publicLinkLimitEnabled: false,
            // Equivalent to: "2020-04-24T05:40:26.0Z"
            creationDate: Date(timeIntervalSince1970: 1587706826)
        )

        let result = Result { try operation.execute(with: .success).await() }

        switch result {
        case .success(let group):
            XCTAssertEqual(group, expectedGroup)
        case .failure(let error):
            XCTFail("Expected success, got: \(error)")
        }
    }

    func testExecute_propagatesUpstreamErrors() {
        let operation = Operation(options:
            .init(
                appBundleId: "com.example.test",
                groupName: "test-group",
                publicLinkEnabled: false,
                publicLinkLimit: nil
            )
        )

        let appsResult = Result { try operation.execute(with: .appsFailure).await() }
        let betaGroupResult = Result { try operation.execute(with: .betaGroupFailure).await() }

        switch (appsResult, betaGroupResult) {
        case (.failure(let appsError as TestError), .failure(let betaGroupError as TestError)):
            XCTAssertEqual(appsError, TestError.somethingBadHappened)
            XCTAssertEqual(betaGroupError, TestError.somethingBadHappened)
        default:
            XCTFail(
                """
                Expected both results to be a failure of type TestError, \
                got: \(appsResult) \(betaGroupResult)
                """
            )
        }
    }

    func testExecute_populatesEndpointBody() {
        let noPublicLinkOrLimitOptions = Options(
            appBundleId: "com.example.test",
            groupName: "test-group",
            publicLinkEnabled: true,
            publicLinkLimit: 10
        )

        var betaGroupEndpoint: APIEndpoint<BetaGroupResponse>?

        let dependencies = Dependencies(
            apps: { _ in Future { $0(.success(Dependencies.appsResponse)) } },
            createBetaGroup: { endpoint in
                betaGroupEndpoint = endpoint
                return Future { $0(.failure(TestError.somethingBadHappened)) }
            }
        )

        _ = try? Operation(options: noPublicLinkOrLimitOptions).execute(with: dependencies).await()

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
}

private extension CreateBetaGroupOperationTests.Dependencies {

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

    static let success = Self(
        apps: { _ in
            Future { $0(.success(appsResponse)) }
        },
        createBetaGroup: { _ in
            Future { $0(.success(betaGroupResponse)) }
        }
    )

    static let appsFailure = Self(
        apps: { _ in
            Future { $0(.failure(TestError.somethingBadHappened)) }
        },
        createBetaGroup: { _ in
            Future { $0(.success(betaGroupResponse)) }
        }
    )

    static let betaGroupFailure = Self(
        apps: { _ in
            Future { $0(.success(appsResponse)) }
        },
        createBetaGroup: { _ in
            Future { $0(.failure(TestError.somethingBadHappened)) }
        }
    )
}
