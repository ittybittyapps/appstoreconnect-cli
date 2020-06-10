// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
@testable import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class ModifyBetaGroupOperationTests: XCTestCase {
    typealias Operation = ModifyBetaGroupOperation
    typealias Options = Operation.Options
    typealias App = AppStoreConnect_Swift_SDK.App
    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    let testUrl = URL(fileURLWithPath: "test")

    var app: App {
        App(
            attributes: App.Attributes(
                bundleId: "com.example.test",
                name: nil,
                primaryLocale: nil,
                sku: nil
            ),
            id: "1234567890",
            relationships: nil,
            links: ResourceLinks(self: testUrl)
        )
    }

    var options: Options {
        Options(
            betaGroup: betaGroup,
            betaGroupName: "New Group Name",
            publicLinkEnabled: true,
            publicLinkLimit: 10,
            publicLinkLimitEnabled: true
        )
    }

    var betaGroup: BetaGroup {
        BetaGroup(
            attributes: nil,
            id: "1234",
            relationships: nil,
            links: ResourceLinks(self: testUrl)
        )
    }

    var betaGroupResponseFuture: Future<BetaGroupResponse, Error> {
        let response =  BetaGroupResponse(
            data: self.betaGroup,
            included: nil,
            links: DocumentLinks(self: URL(fileURLWithPath: "test"))
        )

        return Future { $0(.success(response)) }
    }

    func testSuccess() throws {
        let successRequestor = OneEndpointTestRequestor(
            response: { _ in self.betaGroupResponseFuture }
        )

        let output = try Operation(options: options).execute(with: successRequestor).await()

        XCTAssertEqual(output.id, "1234")
    }

    func testPopulatesModifyRequestBody() throws {
        var requestBody: Data?

        let requestor = OneEndpointTestRequestor<BetaGroupResponse>(
            response: { endpoint in
                requestBody = endpoint.body
                return self.betaGroupResponseFuture
            }
        )

        _ = try Operation(options: options).execute(with: requestor).await()

        guard
            let data = requestBody,
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
            let betaGroup = json["data"] as? NSDictionary,
            let attributes = betaGroup["attributes"] as? NSDictionary
        else {
            XCTFail("Expected attributes to be non-nil!")
            return
        }

        let expectedAttributes: [String: Any] = [
            "name": "New Group Name",
            "publicLinkEnabled": true,
            "publicLinkLimit": 10,
            "publicLinkLimitEnabled": true,
        ]

        XCTAssert(attributes.isEqual(to: expectedAttributes))
    }
}
