// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import FileSystem
import Foundation
import XCTest

final class SyncTestFlightTestersTests: XCTestCase {

    func testCompareTesters() throws {
        let serverTesters = [
            BetaTester(
                email: "foo@gmail.com",
                firstName: nil,
                lastName: nil,
                inviteType: nil),
            BetaTester(
                email: "bar@gmail.com",
                firstName: nil,
                lastName: nil,
                inviteType: nil)
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

    func testCompareBetaGroups() {
        // TODO
    }

    func testCompareTestersInGroup() {
        // TODO
    }

}

extension SyncStrategy: Equatable {
    public static func == (lhs: SyncStrategy<T>, rhs: SyncStrategy<T>) -> Bool {
        switch (lhs, rhs) {
        case (let .create(lhsItem), let .create(rhsItem)):
            return lhsItem == rhsItem
        case (let .update(lhsItem), let .update(rhsItem)):
            return lhsItem == rhsItem
        case (let .delete(lhsItem), let .delete(rhsItem)):
            return lhsItem == rhsItem
        default:
            return false
        }
    }
}
