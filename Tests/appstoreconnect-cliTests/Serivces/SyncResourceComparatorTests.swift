// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import Model
import Foundation
import XCTest

final class SyncResourceComparatorTests: XCTestCase {
    func testCompare_returnCreateStrategies() throws {
        let localGroups = [generateGroup(name: "a new group")]

        let strategies = SyncResourceComparator(
                localResources: localGroups,
                serverResources: []
            )
            .compare()

        XCTAssertEqual(strategies.count, 1)

        XCTAssertEqual(strategies.first!, .create(localGroups.first!))
    }

    func testCompare_returnUpdateStrategies() throws {
        let localGroups = [generateGroup(id: "123", name: "foo")]
        let serverGroups = [generateGroup(id: "123", name: "bar")]

        let strategies = SyncResourceComparator(
                localResources: localGroups,
                serverResources: serverGroups
            )
            .compare()

        XCTAssertEqual(strategies.count, 1)
        XCTAssertEqual(strategies.first!, .update(localGroups.first!))
    }

    func testCompare_returnDelete() {
        let serverGroups = [generateGroup(id: "123"), generateGroup(id: "456")]

        let strategies = SyncResourceComparator(
                localResources: [],
                serverResources: serverGroups
            )
            .compare()

        XCTAssertEqual(strategies.count, 2)
        XCTAssertEqual(strategies.contains(.delete(serverGroups.first!)), true)
        XCTAssertEqual(strategies.contains(.delete(serverGroups[1])), true)
        XCTAssertNotEqual(strategies.contains(.update(generateGroup(id: "1234"))), true)
    }

    func testCompare_returnDeleteAndUpdateAndCreate() {
        let localGroups = [generateGroup(id: "1", publicLinkEnabled: true), generateGroup(name: "hi")]
        let serverGroups = [generateGroup(id: "1", publicLinkEnabled: false), generateGroup(id: "3", name: "there")]

        let strategies = SyncResourceComparator(
                localResources: localGroups,
                serverResources: serverGroups
            )
            .compare()

        XCTAssertEqual(strategies.count, 3)

        XCTAssertEqual(strategies.contains(.delete(serverGroups[1])), true)
        XCTAssertEqual(strategies.contains(.create(localGroups[1])), true)
        XCTAssertEqual(strategies.contains(.update(localGroups[0])), true)
    }
}

private extension SyncResourceComparatorTests {
    func generateGroup(
        id: String? = nil,
        name: String = "foo",
        isInternal: Bool = false,
        publicLinkEnabled: Bool = false,
        publicLinkLimit: Int = 10,
        publicLinkLimitEnabled: Bool = false
    ) -> BetaGroup {
        BetaGroup(
            app: App(id: "", bundleId: "com.example.foo", name: "foo", primaryLocale: "", sku: ""),
            id: id,
            groupName: name,
            isInternal: isInternal,
            publicLink: "",
            publicLinkEnabled: publicLinkEnabled,
            publicLinkLimit: publicLinkLimit,
            publicLinkLimitEnabled: publicLinkLimitEnabled,
            creationDate: "",
            testers: ""
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
