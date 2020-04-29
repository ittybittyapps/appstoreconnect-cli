// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class GetBetaTesterInfoOperationTests: XCTestCase {
    typealias Dependencies = GetBetaTesterInfoOperation.Dependencies

    let options = GetBetaTesterInfoOptions(id: "abc")

    func testExecute_success() {
        let dependencies: Dependencies = .createdSuccess

        let operation = GetBetaTesterInfoOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        switch result {
            case .success(let betaTester):
                XCTAssertEqual(betaTester.betaGroups?[0], "FooGroup")
                XCTAssertEqual(betaTester.apps?[0], "com.example.fooapp")
                XCTAssertEqual(betaTester.apps?[1], "com.example.fooapp")
                XCTAssertEqual(betaTester.firstName, "Foo")
            default:
                XCTFail("Error happened when parsing get beta tester response")
        }
    }

    func testExecute_propagatesUpstreamErrors() {
        let dependencies: Dependencies = .createdFailed

        let operation = GetBetaTesterInfoOperation(options: options)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        let expectedError = TestError.somethingBadHappened

        switch result {
            case .failure(let error as TestError):
                XCTAssertEqual(expectedError, error)
            default:
                XCTFail("Expected failure with: \(expectedError), got: \(result)")
        }
    }
}

private extension GetBetaTesterInfoOperationTests.Dependencies {

    static let createdSuccessResponse = """
    {
      "data": {
        "type": "betaTesters",
        "id": "123456-12345-4276-a6bb-28a5b8f46e32",
        "attributes": {
          "firstName": "Foo",
          "lastName": "Bar",
          "email": "Foo@gmail.com",
          "inviteType": "EMAIL"
        },
        "relationships": {
          "apps": {
            "meta": {
              "paging": {
                "total": 1,
                "limit": 10
              }
            },
            "data": [
              {
                "type": "apps",
                "id": "12345678"
              },
              {
                "type": "apps",
                "id": "12345678"
              }
            ],
          },
          "betaGroups": {
            "meta": {
              "paging": {
                "total": 1,
                "limit": 10
              }
            },
            "data": [
              {
                "type": "betaGroups",
                 "id": "0987654321-0987654321-47c7-9bf8-2f09cd834d73"
              }
            ]
          }
        },
        "links": {
          "self": "https://api.appstoreconnect.apple.com/v1/betaTesters/1234567-b311-4276-a6bb-28a5b8f46e32"
        }
      },
      "included": [
        {
          "type": "apps",
          "id": "12345678",
          "attributes": {
            "name": "FooApp",
            "bundleId": "com.example.fooapp",
            "sku": "com.example.fooapp",
            "primaryLocale": "zh-Hans"
          },
          "links": {
            "self": "https://api.appstoreconnect.apple.com/v1/apps/12345678"
          }
        },
        {
          "type": "betaGroups",
          "id": "0987654321-0987654321-47c7-9bf8-2f09cd834d73",
          "attributes": {
            "name": "FooGroup",
            "createdDate": "2020-03-28T07:53:43.812Z",
            "isInternalGroup": false,
            "publicLinkEnabled": false,
            "publicLinkId": null,
            "publicLinkLimitEnabled": false,
            "publicLinkLimit": null,
            "publicLink": null,
            "feedbackEnabled": true
          },
          "links": {
            "self": "https://api.appstoreconnect.apple.com/v1/betaGroups/0987654321-0987654321-47c7-9bf8-2f09cd834d73"
          }
        }
      ],
      "links": {
        "self": "https://api.appstoreconnect.apple.com/v1/betaTesters/123455678-b311-4276-a6bb-28a5b8f46e32?include=betaGroups%2Capps"
      }
    }
    """.data(using: .utf8)!

    static let createdSuccess = Self(
        betaTesterResponse: { _ in
            Future<BetaTesterResponse, Error> { promise in
                let certificateResponse = try! jsonDecoder
                    .decode(BetaTesterResponse.self, from: createdSuccessResponse)
                promise(.success(certificateResponse))
            }
        }
    )

    static let createdFailed = Self(
        betaTesterResponse: { _ in
            Future<BetaTesterResponse, Error> { promise in
                promise(.failure(TestError.somethingBadHappened))
            }
        }
    )
}

