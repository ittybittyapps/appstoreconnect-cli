// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import XCTest

final class GetUserInfoOperationTests: XCTestCase {

    typealias Options = GetUserInfoOperation.Options
    typealias OperationError = GetUserInfoOperation.Error

    let noUsersRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(noUsersResponse)) }) }
    )

    func testCouldNotFindUserError() {
        let email = "bob@bob.com"
        let options = Options(email: email, includeVisibleApps: false)
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

    static let noUsersResponse: UsersResponse = jsonDecoder.decodeFixture(named: "v1/users/no_user")

}
