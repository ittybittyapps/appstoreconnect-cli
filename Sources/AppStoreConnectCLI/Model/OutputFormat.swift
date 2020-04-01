// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

enum OutputFormat: String, CaseIterable, Codable {
    case csv
    case json
    case table
    case yaml
}

extension OutputFormat: CustomStringConvertible {
    var description: String {
        self.rawValue
    }
}

extension OutputFormat: ExpressibleByArgument {
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

// TODO: move to other file or even share code with `OutputFormat`?

enum InputFormat: String, CaseIterable, Codable {
    case csv
    case json
    case yaml
}

extension InputFormat: CustomStringConvertible {
    var description: String {
        self.rawValue
    }
}

extension InputFormat: ExpressibleByArgument {
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

