// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import CodableCSV
import Combine
import Foundation
import SwiftyTextTable
import Yams

protocol Renderer {
    associatedtype Input

    func render(_ input: Input)
}

private final class StandardErrorOutputStream: TextOutputStream {
    func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }
}

enum Renderers {

    static func null(_ input: Void) {}

    private static var errorOutput = StandardErrorOutputStream()

    struct CompletionRenderer: Renderer {
        func render(_ input: Subscribers.Completion<Error>) {
            switch input {
                case .finished:
                    break
                case .failure(let error):
                    ErrorRenderer().render(error)
            }
        }
    }

    struct ErrorRenderer: Renderer {
        func render(_ input: Error) {
            print("Error: \(input.localizedDescription)", to: &errorOutput)
        }
    }

    struct ResultRenderer<T: ResultRenderable>: Renderer {
        typealias Input = T

        let format: OutputFormat

        func render(_ input: T) {
            switch format {
            case .csv:
                print(input.renderAsCSV())
            case .json:
                print(input.renderAsJSON())
            case .yaml:
                print(input.renderAsYAML())
            case .table:
                print(input.renderAsTable())
            }
        }

    }
}

/// Conformers to this protocol can be rendered as results in various formats.
///
/// By also conforming to `TableInfoProvider`, conformers gain default implementations of all these functions.
protocol ResultRenderable: Codable {
    /// Renders the receiver as a CSV string.
    func renderAsCSV() -> String

    /// Renders the receiver as a JSON string.
    func renderAsJSON() -> String

    /// Renders the receiver as a YAML string.
    func renderAsYAML() -> String

    /// Renders the receiver as a SwiftyTable string.
    func renderAsTable() -> String
}

extension ResultRenderable {
    func renderAsJSON() -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try! jsonEncoder.encode(self)
        return String(data: json, encoding: .utf8)!
    }

    func renderAsYAML() -> String  {
        let yamlEncoder = YAMLEncoder()
        let yaml = try! yamlEncoder.encode(self)
        return yaml
    }
}

/// Provides the necessary info to be able to render a table with SwiftyTable
protocol TableInfoProvider {

    /// Array of columns, with their headers, for display
    static func tableColumns() -> [TextTableColumn]

    /// A single row of table info, in the same order as `Self.tableColumns()`
    var tableRow: [CustomStringConvertible] { get }

}

extension Array: ResultRenderable where Element: TableInfoProvider & Codable {
    func renderAsCSV() -> String {
        let headers = Element.tableColumns().map { $0.header }
        let rows = self.map { $0.tableRow.map { "\($0)" } }
        let wholeTable = [headers] + rows

        return try! CSVWriter.encode(rows: wholeTable, into: String.self)
    }

    func renderAsTable() -> String {
        var table = TextTable(columns: Element.tableColumns())
        table.addRows(values: self.map(\.tableRow))
        return table.render()
    }
}

extension ResultRenderable where Self: TableInfoProvider {
    func renderAsCSV() -> String {
        let headers = Self.tableColumns().map { $0.header }
        let row = self.tableRow.map { "\($0)" }
        let wholeTable = [headers] + [row]

        return try! CSVWriter.encode(rows: wholeTable, into: String.self)
    }

    func renderAsTable() -> String {
        var table = TextTable(columns: Self.tableColumns())
        table.addRow(values: self.tableRow)
        return table.render()
    }
}
