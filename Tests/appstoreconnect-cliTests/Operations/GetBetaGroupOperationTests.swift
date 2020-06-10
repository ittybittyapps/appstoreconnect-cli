// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
@testable import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class GetBetaGroupOperationTests: XCTestCase {
    typealias Operation = GetBetaGroupOperation
    typealias Options = Operation.Options
    typealias App = AppStoreConnect_Swift_SDK.App
    typealias BetaGroup = AppStoreConnect_Swift_SDK.BetaGroup

    let testUrl = URL(fileURLWithPath: "test")

    var options: Options {
        Options(
            appId: "1234567890", bundleId: "com.example.test", betaGroupName: "Some Group"
        )
    }

    var betaGroup: BetaGroup {
        BetaGroup(
            attributes: BetaGroup.Attributes(
                isInternalGroup: false,
                name: "Some Group",
                publicLink: nil,
                publicLinkEnabled: nil,
                publicLinkId: nil,
                publicLinkLimit: nil,
                publicLinkLimitEnabled: nil,
                createdDate: nil
            ),
            id: "1234",
            relationships: nil,
            links: ResourceLinks(self: testUrl)
        )
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
        let successRequestor = OneEndpointTestRequestor(
            response: { _ in self.betaGroupsResponseFuture }
        )

        let output = try Operation(options: options).execute(with: successRequestor).await()

        XCTAssertEqual(output.id, "1234")
    }

    func testBetaGroupNotFound() {
        let betaGroupNotFoundRequestor = OneEndpointTestRequestor(
            response: { (_: APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error> in
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
        case .failure(Operation.Error.betaGroupNotFound(groupName: "Some Group", bundleId: "com.example.test", appId: "1234567890")):
            break
        default:
            XCTFail("Unexpected case!")
        }
    }

    func testBetaGroupNotFoundWithDifferentName() {
        let betaGroup = BetaGroup(
            attributes: BetaGroup.Attributes(
                isInternalGroup: false,
                name: "Just Some Group",
                publicLink: nil,
                publicLinkEnabled: nil,
                publicLinkId: nil,
                publicLinkLimit: nil,
                publicLinkLimitEnabled: nil,
                createdDate: nil
            ),
            id: "5678",
            relationships: nil,
            links: ResourceLinks(self: testUrl)
        )

        let betaGroupNotFoundRequestor = OneEndpointTestRequestor(
            response: { (_: APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error> in
                let response = BetaGroupsResponse(
                    data: [betaGroup],
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
        case .failure(Operation.Error.betaGroupNotFound(groupName: "Some Group", bundleId: "com.example.test", appId: "1234567890")):
            break
        default:
            XCTFail("Unexpected case!")
        }
    }

    func testBetaGroupNotUniqueToApp() {
        let betaGroupNotUniqueRequestor = OneEndpointTestRequestor(
            response: { (_: APIEndpoint<BetaGroupsResponse>) -> Future<BetaGroupsResponse, Error> in
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
        case .failure(Operation.Error.betaGroupNotUniqueToApp(groupName: "Some Group", bundleId: "com.example.test", appId: "1234567890")):
            break
        default:
            XCTFail("Unexpected case!")
        }
    }
}
