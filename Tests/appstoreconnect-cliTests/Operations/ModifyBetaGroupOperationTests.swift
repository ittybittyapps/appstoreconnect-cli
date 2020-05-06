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
            app: app,
            currentGroupName: "Some Group",
            newGroupName: "New Group Name",
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

    var betaGroupsResponseFuture: Future<BetaGroupsResponse, Error> {
        let response = BetaGroupsResponse(
            data: [self.betaGroup],
            included: nil,
            links: PagedDocumentLinks(first: nil, next: nil, self: self.testUrl),
            meta: nil
        )

        return Future { $0(.success(response)) }
    }

    func testSuccess() throws {
        let successRequestor = TwoEndpointTestRequestor(
            response: { _ in self.betaGroupResponseFuture },
            response2: { _ in self.betaGroupsResponseFuture }
        )

        let output = try Operation(options: options).execute(with: successRequestor).await()

        XCTAssertEqual(output.id, "1234")
    }

    func testBetaGroupNotFound() {
        let betaGroupNotFoundRequestor = OneEndpointTestRequestor(
            response: { (endpoint: APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error> in
                let response = BetaGroupsResponse(
                    data: [],
                    included: nil,
                    links: PagedDocumentLinks(first: nil, next: nil, self: self.testUrl),
                    meta: nil
                )

                return Future { $0(.success(response)) }
            }
        )

        let result = Result {
            try Operation(options: options).execute(with: betaGroupNotFoundRequestor).await()
        }

        switch result {
        case .failure(Operation.Error.betaGroupNotFound(groupName: "Some Group", bundleId: "com.example.test")):
            break
        default:
            XCTFail()
        }
    }

    func testBetaGroupNotUniqueToApp() {
        let betaGroupNotUniqueRequestor = OneEndpointTestRequestor(
            response: { (endpoint: APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error> in
                let response = BetaGroupsResponse(
                    data: [self.betaGroup, self.betaGroup],
                    included: nil,
                    links: PagedDocumentLinks(first: nil, next: nil, self: self.testUrl),
                    meta: nil
                )

                return Future { $0(.success(response)) }
            }
        )

        let result = Result {
            try Operation(options: options).execute(with: betaGroupNotUniqueRequestor).await()
        }

        switch result {
        case .failure(Operation.Error.betaGroupNotUniqueToApp(groupName: "Some Group", bundleId: "com.example.test")):
            break
        default:
            XCTFail()
        }
    }

    func testPopulatesModifyRequestBody() throws {
        var requestBody: Data?

        let requestor = TwoEndpointTestRequestor<BetaGroupResponse, BetaGroupsResponse>(
            response: { endpoint in
                requestBody = endpoint.body
                return self.betaGroupResponseFuture
            },
            response2: { _ in self.betaGroupsResponseFuture }
        )

        _ = try Operation(options: options).execute(with: requestor).await()

        guard
            let data = requestBody,
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
            let betaGroup = json["data"] as? NSDictionary,
            let attributes = betaGroup["attributes"] as? NSDictionary
        else {
            XCTFail(); return
        }

        let expectedAttributes: [String: Any] = [
            "name": "New Group Name",
            "publicLinkEnabled": true,
            "publicLinkLimit": 10,
            "publicLinkLimitEnabled": true
        ]

        XCTAssert(attributes.isEqual(to: expectedAttributes))
    }
}
