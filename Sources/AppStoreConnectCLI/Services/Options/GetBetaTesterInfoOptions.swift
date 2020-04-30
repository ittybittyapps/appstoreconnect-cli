// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation

struct GetBetaTesterInfoOptions {
    let email: String
    var limitApps: Int?
    var limitBuilds: Int?
    var limitBetaGroups: Int?
}
