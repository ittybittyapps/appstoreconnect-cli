// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import FileSystem
import Model

struct TestFlightPushCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "push",
        abstract: "Push local TestFlight configuration to the remote API."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Path to read in the TestFlight configuration.")
    var inputPath = "./config/apps"

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        let service = try makeService()

        let local = try FileSystem.readTestFlightConfiguration(from: inputPath)
        let remote = try service.getTestFlightProgram()

        let difference = TestFlightProgramDifference(local: local, remote: remote)

        if dryRun {
            difference.changes.forEach { print($0.description) }
        } else {
            try difference.changes.forEach {
                try performChange(change: $0, with: service)
            }
        }
    }

    func performChange(change: TestFlightProgramDifference.Change, with service: AppStoreConnectService) throws {
        switch change {
        case .removeBetaGroup(let betagroup):
            guard let groupId = betagroup.id else { return }
            try service.deleteBetaGroup(id: groupId)
            print("✅ \(change.description)")
        case .removeBetaTesterFromApps(let tester, let apps):
            guard let email = tester.email else { return }
            try service.removeTesterFromApps(email: email, appIds: apps.map(\.id))
            print("✅ \(change.description)")
        case .removeBetaTesterFromGroups(let tester, let groups):
            guard let email = tester.email else { return }
            try service.removeTesterFromGroups(email: email, groupNames: groups.compactMap(\.groupName))
            print("✅ \(change.description)")
        default:
            print("❌ \(change.description): this operation has not been implemented")
        }
    }

}
