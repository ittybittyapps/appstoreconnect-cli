// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Combine
import XCTest

final class ReadPreReleaseVersionOperationTests: XCTestCase {
    typealias Operation = ReadPreReleaseVersionOperation
    typealias Options = Operation.Options
    typealias OperationError = ReadPreReleaseVersionOperation.Error

    let successResponseRequestor = OneEndpointTestRequestor(response: { _ in
        Future({ $0(.success(onePreRealeseVersionResponse)) }) }
    )

    let noResponseRequestor = OneEndpointTestRequestor(response: { _ in
        Future { $0(.success(noPreReleaseVersionResponse)) }}
    )

    let notUniqueRequestor = OneEndpointTestRequestor(response: { _ in
        Future { $0(.success(notUniqueResponse)) }}
    )

    func testOnePreReleaseVersion() throws {
        let operation = Operation(options: Options(filterAppId: "1504341572", filterVersion: "1.0"))
        let output = try operation.execute(with: successResponseRequestor).await()
        XCTAssertEqual(output.preReleaseVersion.attributes?.version, "1.0")
    }

    func testNoPreReleaseVersion() {
        let operation = Operation(options: Options(filterAppId: "1504341572", filterVersion: "0.0"))

        XCTAssertThrowsError(try operation.execute(with: noResponseRequestor).await()) { error in
            XCTAssertEqual(error as! OperationError, OperationError.noVersionExists)
        }
    }

    func testNotUniquePreReleaseVersion() {
        let operation = Operation(options: Options(filterAppId: "1504341572", filterVersion: "1.0"))

        XCTAssertThrowsError(try operation.execute(with: notUniqueRequestor).await()) { error in
            XCTAssertEqual(error as! OperationError, OperationError.versionNotUnique)
        }
    }

    static let onePreRealeseVersionResponse: PreReleaseVersionsResponse =
    jsonDecoder.decodeFixture(named: "v1/prerelease_version/one_prerelease_version")

    static let notUniqueResponse: PreReleaseVersionsResponse = jsonDecoder.decodeFixture(named: "v1/prerelease_version/not_unique")

    static let noPreReleaseVersionResponse: PreReleaseVersionsResponse =
    jsonDecoder.decodeFixture(named: "v1/prerelease_version/no_prerelease_version")
}
