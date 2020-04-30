// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class GetUserInfoOperationTests: XCTestCase {

    typealias Options = GetUserInfoOperation.Options
    typealias OperationError = GetUserInfoOperation.GetUserInfoError

    let noUsersRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(noUsersResponse)) }) }
    )

    func testCouldNotFindUserError() {
        let email = "bob@bob.com"
        let options = Options(email: email)
        let operation = GetUserInfoOperation(options: options)

        let result = Result {
            try operation.execute(with: noUsersRequestor).await()
        }

        switch result {
        case .failure(OperationError.couldNotFindUser(email)):
            break
        default:
            XCTFail("Expected failure with: \(OperationError.couldNotFindUser(email: email)), got: \(result)")
        }
    }

    static let noUsersResponse = """
    {
      "data" : [],
      "links" : {
        "self" : "https://api.appstoreconnect.apple.com/v1/users?filter%5Busername%5D=bob%40bob.com"
      }
    }
    """
    .data(using: .utf8)
    .map({ try! jsonDecoder.decode(UsersResponse.self, from: $0) })!

}
