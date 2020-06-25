// Copyright 2020 Itty Bitty Apps Pty Ltd

import Files
import Foundation
import XCTest

struct Fixture {
    let data: Data

    init(named: String, in folder: Folder = .tests) throws {
        let file = try folder.file(named: "\(named).json")
        try data = file.read()
    }
}
