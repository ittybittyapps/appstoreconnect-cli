// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation
import Model

struct UserInfoArguments: ParsableArguments {
    @Option(
        parsing: .upToNextOption,
        help: "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform. \(UserRole.allCases)"
    )
    var roles: [Model.UserRole] = []

    @Flag(help: "Indicates that a user has access to all apps available to the team.")
    var allAppsVisible = false

    @Flag(help: "Indicates the user's specified role allows access to the provisioning functionality on the Apple Developer website.")
    var provisioningAllowed = false

    @Option(parsing: .upToNextOption,
            help: "Array of bundle IDs that uniquely identifies the apps.")
    var bundleIds: [String]
}
