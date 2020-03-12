// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

enum OutputFormat: String, CaseIterable, Codable {
    case json = "json"
    case yaml = "yaml"
//    case csv = "csv"
}

extension OutputFormat: ExpressibleByArgument {
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

