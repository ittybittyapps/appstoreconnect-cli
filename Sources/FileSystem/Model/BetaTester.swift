// Copyright 2020 Itty Bitty Apps Pty Ltd

import CodableCSV
import Foundation
import Model

public struct BetaTester: Codable, Equatable, Hashable {
    public var email: String
    public var firstName: String
    public var lastName: String

    public init(
        email: String,
        firstName: String?,
        lastName: String?
    ) {
        self.email = email
        self.firstName = firstName ?? ""
        self.lastName = lastName ?? ""
    }
}

extension BetaTester {

    private enum CodingKeys: String, CodingKey {
        case email = "Email"
        case firstName = "First Name"
        case lastName = "Last Name"
    }

}

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
        ["Email", "First Name", "Last Name"]
    }

    var rows: [[String]] {
        self.map { [$0.email, $0.firstName, $0.lastName] }
    }
}
