// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI

import FileSystem
import Model
import Foundation
import XCTest

final class TestFlightProgramDifferenceTests: XCTestCase {

    func testErrorWillBeThrow_whenDuplicateTesters() throws {
        let local = TestFlightProgram(
            apps: [],
            testers: [BetaTester(email: "foo@gmail.com", firstName: "Foo", lastName: "Bar", inviteType: "EMAIL", betaGroups: [], apps: [])],
            groups: []
        )

        let remote = TestFlightProgram(
            apps: [],
            testers: [
                BetaTester(email: "foo@gmail.com", firstName: "Foo", lastName: "Bar", inviteType: "EMAIL", betaGroups: [], apps: []),
                BetaTester(email: "foo@gmail.com", firstName: "Foo", lastName: "Bar", inviteType: "EMAIL", betaGroups: [], apps: []),
            ],
            groups: []
        )

        XCTAssertThrowsError(try TestFlightProgramDifference(local: local, remote: remote)) { error in
            XCTAssertEqual(
                error as? TestFlightProgramDifference.Error,
                TestFlightProgramDifference.Error.duplicateTesters(email: "foo@gmail.com")
            )
        }
    }

    func testErrorNotThrow_withoutDuplicateTesters() throws {
        let local = TestFlightProgram(
            apps: [],
            testers: [BetaTester(email: "foo@gmail.com", firstName: "Foo", lastName: "Bar", inviteType: "EMAIL", betaGroups: [], apps: [])],
            groups: []
        )

        let remote = TestFlightProgram(
            apps: [],
            testers: [BetaTester(email: "foo@gmail.com", firstName: "Foo", lastName: "Bar", inviteType: "EMAIL", betaGroups: [], apps: [])],
            groups: []
        )

        let result = try TestFlightProgramDifference(local: local, remote: remote)

        XCTAssertTrue(result.changes.isEmpty)
    }

}
