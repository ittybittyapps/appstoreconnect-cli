// Copyright 2020 Itty Bitty Apps Pty Ltd

import CodableCSV
import Foundation
import Model
import Files
import Yams

public struct TestflightConfigurationProcessor {

    let appsFolderPath: String

    public init(appsFolderPath: String) {
        self.appsFolderPath = appsFolderPath
    }

    public func writeConfiguration(
        apps: [Model.App],
        testers: [Model.BetaTester],
        groups: [Model.BetaGroup]
    ) throws {
        // Generate configuration
        let groupsByApp = Dictionary(grouping: groups, by: \.app?.id)

        let configurations: [TestflightConfiguration] = try apps.map { app in
            var config = try TestflightConfiguration(app: FileSystem.App(model: app))

            config.betaTesters = testers
                .filter { tester in tester.apps.map(\.id).contains(app.id) }
                .compactMap(FileSystem.BetaTester.init)

            config.betaGroups = (groupsByApp[app.id] ?? []).map { betaGroup in
                FileSystem.BetaGroup(
                    betaGroup: betaGroup,
                    betaTesters: testers.filter { $0.betaGroups.map(\.id).contains(betaGroup.id) }
                )
            }

            return config
        }

        // Write out the configuration
        let appsFolder = try Folder(path: appsFolderPath)
        try appsFolder.delete()

        let rowsForTesters: ([BetaTester]) -> [[String]] = { testers in
            let headers = [BetaTester.CodingKeys.allCases.map(\.rawValue)]
            let rows = testers.map { [$0.email, $0.firstName, $0.lastName] }
            return headers + rows
        }

        let filenameForBetaGroup: (BetaGroup) -> String = { betaGroup in
            return betaGroup.groupName
                .components(separatedBy: CharacterSet(charactersIn: " *?:/\\."))
                .joined(separator: "_")
                + ".yml"
        }

        try configurations.forEach { config in
            let appFolder = try appsFolder.createSubfolder(named: config.app.bundleId)

            let appFile = try appFolder.createFile(named: "app.yml")
            let appYAML = try YAMLEncoder().encode(config.app)
            try appFile.write(appYAML)

            let testersFile = try appFolder.createFile(named: "beta-testers.csv")
            let testerRows = rowsForTesters(config.betaTesters)
            let testersCSV = try CSVWriter.encode(rows: testerRows, into: String.self)
            try testersFile.write(testersCSV)

            let groupFolder = try appFolder.createSubfolder(named: "betagroups")
            let groupFiles: [(fileName: String, yamlData: String)] = try config.betaGroups.map {
                (filenameForBetaGroup($0), try YAMLEncoder().encode($0))
            }

            try groupFiles.forEach { file in
                try groupFolder.createFile(named: file.fileName).append(file.yamlData)
            }
        }
    }

}
