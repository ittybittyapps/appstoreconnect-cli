// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import XCTest

struct Fixture {
    let data: Data

    init(named: String, in bundle: Bundle = .tests) throws {
        guard
            let url = bundle.url(forResource: named, withExtension: "json") else {
                fatalError("Unable to find fixture named: \(named)")
        }
        try data = Data(contentsOf: url)
    }
}
