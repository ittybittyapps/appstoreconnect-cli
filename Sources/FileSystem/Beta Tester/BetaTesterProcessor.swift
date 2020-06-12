// Copyright 2020 Itty Bitty Apps Pty Ltd

import CodableCSV
import Files
import Foundation
import Model

struct BetaTesterProcessor {

    let folder: Folder

    typealias FilePath = String

    func write(group: BetaGroup, testers: [BetaTester]) throws -> FilePath {
        let file = try folder.createFile(named: "\(group.app.bundleId ?? "")_\(group.groupName)_beta-testers.csv")

        try file.write(testers.renderAsCSV())

        return file.name
    }
}

// TODO: merge this with ResultRenderable in main module
protocol CSVRenderable: Codable {
    var headers: [String] { get }
    var rows: [[String]] { get }
}

extension CSVRenderable {
    func renderAsCSV() -> String {
        let wholeTable = [headers] + rows

        return try! CSVWriter.encode(rows: wholeTable, into: String.self) // swiftlint:disable:this force_try
    }
}

extension Array: CSVRenderable where Element == BetaTester {
    var headers: [String] {
        ["Email", "First Name", "Last Name", "Invite Type"]
    }

    var rows: [[String]] {
        self.map { [$0.email, $0.firstName, $0.lastName, $0.inviteType].compactMap { $0 } }
    }
}
