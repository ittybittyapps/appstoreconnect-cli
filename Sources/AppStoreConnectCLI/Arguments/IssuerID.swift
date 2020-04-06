// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

struct IssuerID: EnvironmentLoadableArgument {
    let argument: String

    init?(argument: String) {
        self.argument = argument
    }
}
