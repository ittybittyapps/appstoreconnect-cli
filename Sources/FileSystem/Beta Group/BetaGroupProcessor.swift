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

    func write(_ betaGroup: BetaGroup) throws -> File {
        try writeFile(betaGroup)
    }

    func read() throws -> [BetaGroup] {
        fatalError()
    }

    public func write(groupsWithTesters: [(betaGroup: BetaGroup, testers: [BetaTester])]) throws {
        deleteFile()

        try groupsWithTesters.map { try write($0.betaGroup) }
    }

}

extension BetaGroup: FileProvider {
    var fileName: String {
        "\(app.id)_\(groupName).yml"
    }

    func fileContent() throws -> FileContent {
        .string(try YAMLEncoder().encode(self))
    }
}
