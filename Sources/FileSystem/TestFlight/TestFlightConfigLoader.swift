// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Files
import Model
import Yams

public struct TestFlightConfigLoader {

    public init() { }

    public func load(appsFolderPath: String) throws -> [TestFlightConfiguration] {
        try Folder(path: appsFolderPath).subfolders.map {
            try load(in: $0)
        }
    }

    func load(in appFolder: Folder) throws -> TestFlightConfiguration {

        let appFile = try appFolder.file(named: "app.yml")
        let app: Model.App = Readers.FileReader<Model.App>(format: .yaml)
            .readYAML(from: appFile.path)

        let testersFile = try appFolder.file(named: "beta-testers.csv")

        let testers: [BetaTester] = Readers.FileReader<[BetaTester]>(format: .csv)
            .readCSV(from: testersFile.path)

        let betagroupsFolder = try appFolder.subfolder(named: "betagroups")
        let betagroups: [BetaGroup] = betagroupsFolder.files.map {
            Readers
                .FileReader<BetaGroup>(format: .yaml)
                .readYAML(from: $0.path)
        }

        return TestFlightConfiguration(app: app, testers: testers, betagroups: betagroups)
    }

    func save(_ config: TestFlightConfiguration, in appFolder: Folder) throws {
        let appFile = try appFolder.createFile(named: "app.yml")
        try appFile.write(try YAMLEncoder().encode(config.app))

        let testersFile = try appFolder.createFile(named: "beta-testers.csv")
        try testersFile.write(config.testers.renderAsCSV())

        let groupFolder = try appFolder.createSubfolder(named: "betagroups")
        try config.betagroups.forEach {
            try groupFolder.createFile(named: "\($0.groupName.filenameSafe()).yml").append(try YAMLEncoder().encode($0))
        }
    }

    public func save(_ config: [TestFlightConfiguration], in appsFolderPath: String) throws {
        let appsFolder = try Folder(path: appsFolderPath)

        try appsFolder.delete()

        try config.forEach {
            let appFolder = try appsFolder.createSubfolder(named: $0.app.bundleId!)

            try save($0, in: appFolder)
        }
    }
}
