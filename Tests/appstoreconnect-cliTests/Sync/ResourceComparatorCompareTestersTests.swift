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

    private func generateGroupWithTesters(
        emails: [String]
    ) -> BetaGroup {
        BetaGroup(
            id: "0001",
            groupName: name,
            isInternal: true,
            publicLink: "",
            publicLinkEnabled: true,
            publicLinkLimit: 10,
            publicLinkLimitEnabled: true,
            creationDate: "",
            testers: emails
        )
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
