// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

public struct ListUsersCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of the users on your team.")

    public init() {
    }

    @Option(help: "Limit the number of users to return (maximum 200).")
    var limit: Int?

    @Option(help: "Sort the results in the specified order.")
    var sort: String?

    @Option(help: "Filter the results by the specified username")
    var filterUsername: String?

    @Option(help: "Filter the results by the specified roles")
    var filterRole: UserRole?

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

    public func run() throws {
        // TODO
        print(self.sort as Any)
    }
}

extension UserRole: ExpressibleByArgument {
}
