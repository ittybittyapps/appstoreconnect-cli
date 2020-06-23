// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Foundation
import Combine
import XCTest

final class ListPreReleaseVersionsOperationTests: XCTestCase {
    typealias Operation = ListPreReleaseVersionsOperation
    typealias Options = Operation.Options

    let successRequestor = OneEndpointTestRequestor(
        response: { _ in Future({ $0(.success(dataResponse)) }) }
    )

    func testReturnsOnePreReleaseVersion() throws {
        let operation = Operation(options: Options(filterAppIds: [], filterVersions: [], filterPlatforms: [], sort: nil))
        let output = try operation.execute(with: successRequestor).await()
        XCTAssertEqual(output.first?.preReleaseVersion.attributes?.version, "1.1")
    }

    static let dataResponse: PreReleaseVersionsResponse = jsonDecoder.decodeFixture(named: "v1/prerelease_version/list_prerelease_version")
}
