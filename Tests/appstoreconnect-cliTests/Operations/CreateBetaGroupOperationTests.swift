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
            XCTFail("Expected app data to be non-nil!")
            return
        }

        XCTAssertEqual(appData["id"] as? String, "0123456789")
        XCTAssertEqual(attributes["name"] as? String, "test-group")
        XCTAssertEqual(attributes["publicLinkLimitEnabled"] as? Bool, true)
        XCTAssertEqual(attributes["publicLinkEnabled"] as? Bool, true)
        XCTAssertEqual(attributes["publicLinkLimit"] as? Int, 10)
    }

    static let appsResponse: AppsResponse = jsonDecoder.decodeFixture(named: "v1/apps/app_response")

    static let betaGroupResponse: BetaGroupResponse = jsonDecoder.decodeFixture(named: "v1/betagroups/betagroup_response")
}
