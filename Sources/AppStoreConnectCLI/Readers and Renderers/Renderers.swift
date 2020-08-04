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

enum Renderers {
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
        let json = try! jsonEncoder.encode(self) // swiftlint:disable:this force_try
        return String(data: json, encoding: .utf8)!
    }

    func renderAsYAML() -> String {
        let yamlEncoder = YAMLEncoder()
        let yaml = try! yamlEncoder.encode(self) // swiftlint:disable:this force_try
        return yaml
    }

    func render(format: OutputFormat) {
        Renderers.ResultRenderer(format: format).render(self)
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

        return try! CSVWriter.encode(rows: wholeTable, into: String.self) // swiftlint:disable:this force_try
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

        return try! CSVWriter.encode(rows: wholeTable, into: String.self) // swiftlint:disable:this force_try
    }

    func renderAsTable() -> String {
        var table = TextTable(columns: Self.tableColumns())
        table.addRow(values: self.tableRow)
        return table.render()
    }
}

protocol SyncResultRenderable: Equatable {
    var syncResultText: String { get }
}

struct SyncResultRenderer<T: SyncResultRenderable> {
    func render(_ strategy: [SyncAction<T>], isDryRun: Bool) {
        strategy.forEach { renderResultText($0, isDryRun) }
    }

    func render(_ strategy: SyncAction<T>, isDryRun: Bool) {
        renderResultText(strategy, isDryRun)
    }

    private func renderResultText(_ strategy: SyncAction<T>, _ isDryRun: Bool) {
        let resultText: String
        switch strategy {
        case .create(let input):
            resultText = "➕ \(input.syncResultText)"
        case .delete(let input):
            resultText = "➖\(input.syncResultText)"
        case .update(let input):
            resultText = "⬆️ \(input.syncResultText)"
        }

        print("\(isDryRun ? "" : "✅") \(resultText)")
    }
}
