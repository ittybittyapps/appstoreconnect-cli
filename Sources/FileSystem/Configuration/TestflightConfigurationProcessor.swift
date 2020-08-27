// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct TestflightConfigurationProcessor: ResourceWriter {

    let path: ResourcePath

    public init(path: ResourcePath) {
        self.path = path
    }

}
