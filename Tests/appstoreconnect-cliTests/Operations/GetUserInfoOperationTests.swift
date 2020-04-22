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
        let email = "bob@bob.com"
        let options = Options(email: email)
        let operation = GetUserInfoOperation(options: options)
        let expectedError = OperationError.couldNotFindUser(email: email)

        let result = Result {
            try operation.execute(with: dependencies).await()
        }

        switch result {
        case .failure(let error as OperationError):
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        default:
            XCTFail("Expected failure with: \(expectedError), got: \(result)")
        }
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
            Future<UsersResponse, Error> { promise in
                let usersResponse = try! jsonDecoder
                    .decode(UsersResponse.self, from: noUsersResponse)
                promise(.success(usersResponse))
            }
        }
    )
}
