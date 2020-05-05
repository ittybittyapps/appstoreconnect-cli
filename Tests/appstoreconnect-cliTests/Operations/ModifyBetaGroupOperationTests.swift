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
            newGroupName: nil,
            publicLinkEnabled: nil,
            publicLinkLimit: nil,
            publicLinkLimitEnabled: nil
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

    func testSuccess() throws {
        let successRequestor = TwoEndpointTestRequestor(
            response: { (endpoint: APIEndpoint<BetaGroupResponse>) -> Future<BetaGroupResponse, Error> in
                let response =  BetaGroupResponse(
                    data: self.betaGroup,
                    included: nil,
                    links: DocumentLinks(self: URL(fileURLWithPath: "test"))
                )

                return Future { $0(.success(response)) }
            },
            response2: { (endpoint: APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error> in
                let response = BetaGroupsResponse(
                    data: [self.betaGroup],
                    included: nil,
                    links: PagedDocumentLinks(first: nil, next: nil, self: self.testUrl),
                    meta: nil
                )

                return Future { $0(.success(response)) }
            }
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
}
