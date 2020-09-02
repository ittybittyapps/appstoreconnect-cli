// Copyright 2020 Itty Bitty Apps Pty Ltd

import CodableCSV
import Foundation
import Model
import Files
import Yams

struct TestflightConfigurationProcessor {

    let path: String

    init(path: String) {
        self.path = path
    }

    func writeConfiguration(_ configuration: TestflightConfiguration) throws {
        let appsFolder = try Folder(path: path)
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

        try configuration.appConfigurations.forEach { config in
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

    func readConfiguration() throws -> TestflightConfiguration {
        let folder = try Folder(path: path)
        var configurations: [TestflightConfiguration.AppConfiguration] = []

        let decodeBetaTesters: (Data) throws -> [BetaTester] = { data in
            var configuration = CSVReader.Configuration()
            configuration.headerStrategy = .firstLine

            let csv = try CSVReader.decode(input: data, configuration: configuration)

            return try csv.records.map { record in
                try BetaTester(
                    email: record[BetaTester.CodingKeys.email.rawValue],
                    firstName: record[BetaTester.CodingKeys.firstName.rawValue],
                    lastName: record[BetaTester.CodingKeys.lastName.rawValue]
                )
            }
        }

        for appFolder in folder.subfolders {
            let appYAML = try appFolder.file(named: "app.yml").readAsString()
            let app = try YAMLDecoder().decode(from: appYAML) as App

            var appConfiguration = TestflightConfiguration.AppConfiguration(app: app)

            let testersFile = try appFolder.file(named: "beta-testers.csv")
            appConfiguration.betaTesters = try decodeBetaTesters(try testersFile.read())

            let groupsFolder = try appFolder.subfolder(named: "betagroups")
            appConfiguration.betaGroups = try groupsFolder.files.map { groupFile in
                try YAMLDecoder().decode(from: try groupFile.readAsString())
            }

            configurations += [appConfiguration]
        }

        return TestflightConfiguration(appConfigurations: configurations)
    }

}
