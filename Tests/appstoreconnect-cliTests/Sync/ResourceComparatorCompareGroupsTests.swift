// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import FileSystem
import Foundation
import XCTest

final class ResourceComparatorCompareGroupsTests: XCTestCase {

    func testCompareBetaGroups() {
        let localBetaGroups = [
            generateGroup(id: nil, name: "group to create", publicLinkEnabled: true),
            generateGroup(id: "1002", name: "group to update", publicLinkEnabled: false),
        ]

        let serverBetaGroups = [
            generateGroup(id: "1002", name: "group to update", publicLinkEnabled: true),
            generateGroup(id: "1003", name: "group to delete", publicLinkEnabled: true),
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

    private func generateGroup(
        id: String?,
        name: String,
        publicLinkEnabled: Bool = true,
        publicLinkLimitEnabled: Bool = true
    ) -> BetaGroup {
        BetaGroup(
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
