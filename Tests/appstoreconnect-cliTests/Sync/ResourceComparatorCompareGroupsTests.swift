// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import FileSystem
import Foundation
import XCTest

final class ResourceComparatorCompareGroupsTests: XCTestCase {

    func testCompareBetaGroups() {
        let localBetaGroups = [
            BetaGroup(id: nil, name: "group to create", publicLinkEnabled: true),
            BetaGroup(id: "1002", name: "group to update", publicLinkEnabled: false),
        ]

        let serverBetaGroups = [
            BetaGroup(id: "1002", name: "group to update", publicLinkEnabled: true),
            BetaGroup(id: "1003", name: "group to delete", publicLinkEnabled: true),
        ]

        let strategies = SyncResourceComparator(
                localResources: localBetaGroups,
                serverResources: serverBetaGroups
            )
            .compare()

        XCTAssertEqual(strategies.count, 3)

        XCTAssertTrue(strategies.contains(where: {
            $0 == .delete(serverBetaGroups[1])
        }))

        XCTAssertTrue(strategies.contains(where: {
            $0 == .create(localBetaGroups[0])
        }))

        XCTAssertTrue(strategies.contains(where: {
            $0 == .update(localBetaGroups[1])
        }))
    }

}

private extension BetaGroup {
    init(
        id: String?,
        name: String,
        publicLinkEnabled: Bool = true,
        publicLinkLimitEnabled: Bool = true
    ) {
        self = BetaGroup(
            id: id,
            groupName: name,
            isInternal: true,
            publicLink: "",
            publicLinkEnabled: publicLinkEnabled,
            publicLinkLimit: 10,
            publicLinkLimitEnabled: publicLinkLimitEnabled,
            creationDate: "",
            testers: []
        )
    }
}
