// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Model

public func writeTestflightConfiguration(program: TestflightProgram, to folderPath: String) throws {
    let configuration = try TestflightConfiguration(program: program)

    let processor = TestflightConfigurationProcessor(appsFolderPath: folderPath)
    try processor.writeConfiguration(configuration)
}

public func readTestflightConfiguration() throws -> TestflightProgram {
    return TestflightProgram(apps: [], testers: [], groups: [])
}
