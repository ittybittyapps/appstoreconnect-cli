// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public func writeTestflightConfiguration(program: TestflightProgram, to folderPath: String) throws {
    let configuration = try TestflightConfiguration(program: program)

    let processor = TestflightConfigurationProcessor(path: folderPath)
    try processor.writeConfiguration(configuration)
}

public func readTestflightConfiguration(from folderPath: String) throws -> TestflightProgram {
    let processor = TestflightConfigurationProcessor(path: folderPath)

    return TestflightProgram(apps: [], testers: [], groups: [])
}
