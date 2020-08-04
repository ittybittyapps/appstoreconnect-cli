// Copyright 2020 Itty Bitty Apps Pty Ltd

import Files
import Foundation
import Model
import Yams

public struct TestFlightConfiguration: Codable, Equatable {
    public let app: Model.App
    public let testers: [BetaTester]
    public let betagroups: [BetaGroup]

    public init(
        app: Model.App,
        testers: [BetaTester],
        betagroups: [BetaGroup]
    ) {
        self.app = app
        self.testers = testers
        self.betagroups = betagroups
    }
}

extension TestFlightConfiguration {
    func save(in appFolder: Folder) throws {
        let appFile = try appFolder.createFile(named: "app.yml")
        try appFile.write(try YAMLEncoder().encode(self.app))

        let testersFile = try appFolder.createFile(named: "beta-testers.csv")
        try testersFile.write(self.testers.renderAsCSV())

        let groupFolder = try appFolder.createSubfolder(named: "betagroups")

        try self.betagroups.forEach {
            try groupFolder
                .createFile(named: "\($0.groupName.filenameSafe()).yml")
                .append(try YAMLEncoder().encode($0))
        }
    }

    init(from appFolder: Folder) throws {
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

        self = TestFlightConfiguration(app: app, testers: testers, betagroups: betagroups)
    }
}

extension Array where Element == TestFlightConfiguration {
    public func save(in appsFolderPath: String) throws {
        let appsFolder = try Folder(path: appsFolderPath)

        try appsFolder.delete()

        try self.forEach {
            let appFolder = try appsFolder.createSubfolder(named: $0.app.bundleId!)
            try $0.save(in: appFolder)
        }
    }

    public init(from appsFolderPath: String) throws {
        self = try Folder(path: appsFolderPath).subfolders.map {
            try TestFlightConfiguration(from: $0)
        }
    }

    public init(from appsFolderPath: String, with buildIds: [String]) throws {
        if buildIds.isEmpty {
            try self.init(from: appsFolderPath)
        } else {
            self = try Folder(path: appsFolderPath).subfolders.compactMap {
                if buildIds.contains($0.name) {
                    return try TestFlightConfiguration(from: $0)
                }
                return nil
            }
        }
    }
}
