// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import FileSystem
import Foundation
import XCTest

final class ResourceComparatorCompareTestersTests: XCTestCase {

    func testCompareTesters() {
        let serverTesters = [
            BetaTester(
                email: "foo@gmail.com",
                firstName: nil,
                lastName: nil),
            BetaTester(
                email: "bar@gmail.com",
                firstName: nil,
                lastName: nil),
        ]

        let localTesters: [BetaTester] = []

        let strategies = SyncResourceComparator(localResources: localTesters, serverResources: serverTesters).compare()

        XCTAssertEqual(strategies.count, 2)

        XCTAssertTrue(strategies.contains(where: {
            $0 == .delete(serverTesters[0])
        }))

        XCTAssertTrue(strategies.contains(where: {
            $0 == .delete(serverTesters[1])
        }))
    }

    func testCompareTestersInGroups() {
        let serverTestersInGroup = ["foo@gmail.com", "bar@gmail.com"]

        let localTestersInGroup = ["hi@gmail.com", "hello@gmail.com", "foo@gmail.com"]

        let strategies = SyncResourceComparator(
                localResources: localTestersInGroup,
                serverResources: serverTestersInGroup
            )
            .compare()

        XCTAssertEqual(strategies.count, 3)

        XCTAssertTrue(strategies.contains(where: {
            $0 == .delete(serverTestersInGroup[1])
        }))

        XCTAssertTrue(strategies.contains(where: {
            $0 == .create(localTestersInGroup[0])
        }))

        XCTAssertTrue(strategies.contains(where: {
            $0 == .create(localTestersInGroup[1])
        }))
    }

}
