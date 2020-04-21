// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class GetUserInfoOperationTests: XCTestCase {
    typealias Dependencies = GetUserInfoOperation.Dependencies
    typealias Options = GetUserInfoOperation.Options
    typealias OperationError = GetUserInfoOperation.GetUserInfoError

    func testCouldNotFindUserError() {
        let dependencies: Dependencies = .noUsers
        let options = Options(email: "bob@bob.com")
        let operation = GetUserInfoOperation(options: options)

        let expectation = XCTestExpectation(description: "Publisher will complete")
        var operationError: Error?

        _ = operation
            .execute(with: dependencies)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        operationError = error
                    }

                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected no values")
                }
            )

        XCTAssertEqual(
            operationError?.localizedDescription,
            OperationError.couldNotFindUser(email: "bob@bob.com").localizedDescription
        )
    }
}

private extension GetUserInfoOperationTests.Dependencies {
    static let jsonDecoder = JSONDecoder()

    static let noUsersResponse = """
    {
      "data" : [ ],
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/users?filter%5Busername%5D=bob%40bob.com"
      },
      "meta" : {
        "paging" : {
          "total" : 0,
          "limit" : 50
        }
      }
    }
    """.data(using: .utf8)!

    static let noUsers = Self(
        usersResponse: { _ in
            let response = try! jsonDecoder.decode(UsersResponse.self, from: noUsersResponse)
            return Future<UsersResponse, Error> { $0(.success(response)) }
        }
    )
}
