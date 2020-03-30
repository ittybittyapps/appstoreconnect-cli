// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

enum OutputFormat: String, CaseIterable, Codable {
    case csv
    case json
    case table
    case yaml
}

extension OutputFormat: ExpressibleByArgument {
    init?(argument: String) {
        self.init(rawValue: argument.lowercased())
    }
}

