// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public enum InputFormat: String, CaseIterable, Codable {
    case json
    case yaml
    case csv
    case txt
}
