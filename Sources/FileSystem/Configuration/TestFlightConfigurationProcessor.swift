// Copyright 2020 Itty Bitty Apps Pty Ltd

import CodableCSV
import Foundation
import Model
import Files
import Yams

struct TestFlightConfigurationProcessor {

    let path: String

    init(path: String) {
        self.path = path
    }

    private static let appYAMLName = "app.yml"
    private static let betaTestersCSVName = "beta-testers.csv"
    private static let betaGroupFolderName = "betagroups"

    func writeConfiguration(_ configuration: TestFlightConfiguration) throws {
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

            let appFile = try appFolder.createFile(named: Self.appYAMLName)
            let appYAML = try YAMLEncoder().encode(config.app)
            try appFile.write(appYAML)

            let testersFile = try appFolder.createFile(named: Self.betaTestersCSVName)
            let testerRows = rowsForTesters(config.betaTesters)
            let testersCSV = try CSVWriter.encode(rows: testerRows, into: String.self)
            try testersFile.write(testersCSV)

            let groupFolder = try appFolder.createSubfolder(named: Self.betaGroupFolderName)
            let groupFiles: [(fileName: String, yamlData: String)] = try config.betaGroups.map {
                (filenameForBetaGroup($0), try YAMLEncoder().encode($0))
            }

            try groupFiles.forEach { file in
                try groupFolder.createFile(named: file.fileName).append(file.yamlData)
            }
        }
    }

    enum Error: LocalizedError {
        case testerNotInTestersList(email: String, betaGroup: BetaGroup, app: App)
        case noValidApp

        var errorDescription: String? {
            switch self {
            case .testerNotInTestersList(let email, let betaGroup, let app):
                return "Tester with email: \(email) in beta group named: \(betaGroup.groupName) " +
                    "for app: \(app.bundleId) is not included in the \(betaTestersCSVName) file"

            case .noValidApp:
                return "There's no valid app folder found in your local configuration file path, please run 'sync pull' first"
            }
        }
    }

    func readConfiguration() throws -> TestFlightConfiguration {
        let folder = try Folder(path: path)

        guard folder.subfolders.count() > 0 else { throw Error.noValidApp }

        var configuration = TestFlightConfiguration()

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

        configuration.appConfigurations = try folder.subfolders.map { appFolder in
            let appYAML = try appFolder.file(named: Self.appYAMLName).readAsString()
            let app = try YAMLDecoder().decode(from: appYAML) as App

            var appConfiguration = TestFlightConfiguration.AppConfiguration(app: app)

            let testersFile = try appFolder.file(named: Self.betaTestersCSVName)
            let betaTesters = try decodeBetaTesters(try testersFile.read())
            appConfiguration.betaTesters = betaTesters

            let groupsFolder = try appFolder.subfolder(named: Self.betaGroupFolderName)
            let emails = betaTesters.map(\.email)
            appConfiguration.betaGroups = try groupsFolder.files.map { groupFile -> BetaGroup in
                let group: BetaGroup = try YAMLDecoder().decode(from: try groupFile.readAsString())

                if let email = group.testers.first(where: { !emails.contains($0) }) {
                    throw Error.testerNotInTestersList(email: email, betaGroup: group, app: app)
                }

                return group
            }

            return appConfiguration
        }

        return configuration
    }

}
