// Copyright 2020 Itty Bitty Apps Pty Ltd

import Files
import Foundation
import Model
import Yams

public struct BetaGroupProcessor: ResourceProcessor {

    var path: ResourcePath

    public init(path: ResourcePath) {
        self.path = path
    }

    public func read() throws -> [BetaGroup] {
        try getFolder().files.compactMap { (file: File) -> BetaGroup? in
            if file.extension == "yml" {
                return Readers
                    .FileReader<BetaGroup>(format: .yaml)
                    .read(filePath: file.path)
            }

            return nil
        }
    }

    public func write(groupsWithTesters: [(betaGroup: BetaGroup, testers: [BetaTester])]) throws {
        deleteFile()

        let betagroups = try groupsWithTesters
            .map { try write(betaTesters: $0.testers, into: $0.betaGroup) }

        try write(betagroups)
    }

    @discardableResult
    func write(_ betaGroups: [BetaGroup]) throws -> [File] {
        try betaGroups.map { try write($0) }
    }

    @discardableResult
    func write(_ betaGroup: BetaGroup) throws -> File {
        try writeFile(betaGroup)
    }

    private func write(betaTesters: [BetaTester], into betaGroup: BetaGroup) throws -> BetaGroup {

        var group = betaGroup
        group.testers = try BetaTesterProcessor(folder: try getFolder())
            .write(group: group, testers: betaTesters)

        return group
    }

}

extension BetaGroup: FileProvider {
    var fileName: String {
        "\(app.bundleId ?? "")_\(groupName).yml"
    }

    func fileContent() throws -> FileContent {
        .string(try YAMLEncoder().encode(self))
    }
}
