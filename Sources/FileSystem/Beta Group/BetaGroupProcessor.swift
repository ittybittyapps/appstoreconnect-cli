// Copyright 2020 Itty Bitty Apps Pty Ltd

import Files
import Foundation
import Model
import Yams

public struct BetaGroupProcessor: ResourceProcessor {

    public init(path: ResourcePath) {
        self.path = path
    }

    func write(_: [BetaGroup]) throws -> [File] {
        fatalError()
    }

    var path: ResourcePath

    @discardableResult
    func write(_ betaGroup: BetaGroup) throws -> File {
        try writeFile(betaGroup)
    }

    func read() throws -> [BetaGroup] {
        fatalError()
    }

    public func write(groupsWithTesters: [(betaGroup: BetaGroup, testers: [BetaTester])]) throws {
        deleteFile()

        let betagroups = try groupsWithTesters
            .map { try write(betaTesters: $0.testers, into: $0.betaGroup) }

        try betagroups.forEach { try write($0) }
    }

    private func write(betaTesters: [BetaTester], into betaGroup: BetaGroup) throws -> BetaGroup {
        let testerProcessor = BetaTesterProcessor(folder: try getFolder())

        var group = betaGroup
        group.testers = try testerProcessor.write(group: group, testers: betaTesters)

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
