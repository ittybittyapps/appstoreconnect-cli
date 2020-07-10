// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem
import Foundation

struct TestFlightPushCommand: CommonParsableCommand {

    static var configuration =  CommandConfiguration(
        commandName: "push",
        abstract: "Push local testflight config files to server, update server configs"
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(
        default: "./config/apps",
        help: "Path to the Folder containing the testflight configs."
    ) var inputPath: String

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        let service = try makeService()

        let localConfigs = try TestFlightConfigLoader().load(appsFolderPath: inputPath)

        let serverConfigs = try service.pullTestFlightConfigs()

        serverConfigs.forEach { serverConfig in
            guard
                let localConfig = localConfigs
                    .first(where: { $0.app.id == serverConfig.app.id }) else {
                return
            }

            let appId = localConfig.app.id

            // 1. compare shared testers in app
            let sharedTestersHandleStrategies = SyncResourceComparator(
                localResources: localConfig.testers,
                serverResources: serverConfig.testers
            ).compare()

            // 1.1 handle shared testers delete only
            processAppTesterStrategies(sharedTestersHandleStrategies, appId: appId)


            // 2. compare beta groups
            let localBetagroups = localConfig.betagroups
            let serverBetagroups = serverConfig.betagroups

            let betaGroupHandlingStrategies = SyncResourceComparator(
                    localResources: localBetagroups,
                    serverResources: serverBetagroups
                )
                .compare()

            // 2.1 handle groups create, update, delete
            processBetagroupsStrategies(betaGroupHandlingStrategies, appId: appId)


            // 3. compare testers in group and add, delete
            localBetagroups.forEach { localBetagroup in
                guard let serverBetagroup = serverBetagroups
                    .first(where: {  $0.id == localBetagroup.id } ) else {
                        return
                }

                let betagroupId = serverBetagroup.id

                let localGroupTesters = localBetagroup.testers

                let serverGroupTesters = serverBetagroup.testers

                let testersInGroupHandlingStrategies = SyncResourceComparator(
                    localResources: localGroupTesters,
                    serverResources: serverGroupTesters
                ).compare()

                // 3.1 handling adding/deleting testers per group
                processTestersInBetaGroupStrategies(testersInGroupHandlingStrategies, betagroupId: betagroupId, appTesters: localConfig.testers)
            }
        }
    }

    func processAppTesterStrategies(_ strategies: [SyncStrategy<FileSystem.BetaTester>], appId: String) {
        if dryRun {
            SyncResultRenderer<FileSystem.BetaTester>().render(strategies, isDryRun: true)
        } else {
            strategies.forEach { strategy in
                switch strategy {
                case .delete(let betatester):
                    print("delete testers \(betatester) from app \(appId)")
                default:
                    return
                }
            }
        }

    }

    func processBetagroupsStrategies(_ strategies: [SyncStrategy<FileSystem.BetaGroup>], appId: String) {
        if dryRun {
            SyncResultRenderer<FileSystem.BetaGroup>().render(strategies, isDryRun: true)
        } else {
            strategies.forEach { strategy in
                switch strategy {
                case .create(let betagroup):
                    print("create new beta group \(betagroup) in app \(appId)")
                case .delete(let betagroup):
                    print("delete betagroup \(betagroup)")
                case .update(let betagroup):
                    print("update betagroup \(betagroup)")
                }
            }
        }

    }

    func processTestersInBetaGroupStrategies(_ strategies: [SyncStrategy<BetaGroup.EmailAddress>], betagroupId: String, appTesters: [BetaTester]) {
        if dryRun {
            SyncResultRenderer<FileSystem.BetaGroup.EmailAddress>().render(strategies, isDryRun: true)
        } else {
            strategies.forEach { strategy in
                switch strategy {
                case .create(let email):
                    print("add tester with email\(email) into betagroup\(betagroupId)")
                case .delete(let email):
                    print("delete tester with email \(email) from betagroup \(betagroupId)")
                default:
                    return
                }
            }
        }
    }

}


func testPrint<T: Codable>(json: T) {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let json = try! jsonEncoder.encode(json) // swiftlint:disable:this force_try
    print(String(data: json, encoding: .utf8)!)
}
