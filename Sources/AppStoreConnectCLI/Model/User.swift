// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK

struct User: Codable {
    var username: String
    var firstName: String
    var lastName: String
    var roles: [UserRole]
    var provisioningAllowed: Bool
    var allAppsVisible: Bool
    var visibleApps: [String]?
}
