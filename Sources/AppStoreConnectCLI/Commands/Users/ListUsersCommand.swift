// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation
import SwiftyTextTable
import Yams

public struct ListUsersCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of the users on your team.")

    public init() {}

    @Option(help: "Limit the number of users to return (maximum 200).")
    var limit: Int?

    @Option(
        parsing: SingleValueParsingStrategy.unconditional,
        help: "Sort the results using the provided key (\(UserSorting.allCases.map { $0.rawValue }.joined(separator: ", "))).\nThe `-` prefix indicates descending order."
    )
    var sort: UserSorting?

    @Option(
        help: "Filter the results by the specified username.",
        transform: { $0.lowercased() }
    )
    var filterUsername: String?

    @Option(
        parsing: ArrayParsingStrategy.singleValue,
        help: ArgumentHelp(stringLiteral: "Filter the results by the specified roles (\(UserRole.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    )
    var filterRole: [UserRole?]

    @Option(
        parsing: ArrayParsingStrategy.singleValue,
        help: ArgumentHelp(stringLiteral: "Filter the results by the app(s) visible to each user.\nUsers with access to all apps will always be included."),
        transform: { $0.lowercased() }
    )
    var filterVisibleApps: [String?]

    @Flag(help: "Include visible apps in results.")
    var includeVisibleApps: Bool

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    public func run() throws {
        var users = getMockUsers()

        if let filterUsername = filterUsername {
            users = users
                .filter { $0.username.lowercased().contains(filterUsername) }
        }

        if !filterRole.isEmpty {
            let roles = Set(filterRole)
            users = users
                .filter { !roles.intersection($0.roles).isEmpty }
        }

        if !filterVisibleApps.isEmpty {
            let apps = Set(filterVisibleApps.compactMap { $0 })
            users = users
                .filter { user in
                    guard let userApps = user.visibleApps else {
                        return user.allAppsVisible
                    }
                    return user.allAppsVisible
                        || !apps.intersection(userApps).isEmpty
            }
        }

        if let sort = sort {
            users = users.sorted { a, b in
                switch sort {
                    case .lastName:
                        return a.lastName < b.lastName
                    case .lastNameDesc:
                        return a.lastName > b.lastName
                    case .username:
                        return a.username < b.username
                    case .usernameDesc:
                        return a.username > b.username
                }
            }
        }

        if let outputFormat = outputFormat {
            do {
                switch outputFormat {
                case .json:
                    let jsonEncoder = JSONEncoder()
                    if #available(OSX 10.13, *) {
                        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    } else {
                        jsonEncoder.outputFormatting = [.prettyPrinted]
                    }

                    let redactedUsers = includeVisibleApps
                        ? users
                        : users.map { user in
                            var copy = user
                            copy.visibleApps = nil
                            return copy
                        }

                    let json = try jsonEncoder.encode(redactedUsers)
                    print(String(data: json, encoding: .utf8)!)
                case .yaml:
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try yamlEncoder.encode(users)
                    print("users:\n" + yaml)
                }
            } catch {
                print(error)
            }

        } else {
            var columns = [
                TextTableColumn(header: "Username"),
                TextTableColumn(header: "First Name"),
                TextTableColumn(header: "Last Name"),
                TextTableColumn(header: "Role"),
                TextTableColumn(header: "Provisioning Allowed"),
                TextTableColumn(header: "All Apps Visible")
            ]

            if includeVisibleApps {
                columns.append(TextTableColumn(header: "Visible Apps"))
            }

            var table = TextTable(columns: columns)

            users.forEach { user in
                table.addRow(values: [
                    user.username,
                    user.firstName,
                    user.lastName,
                    user.roles.map { $0.rawValue }.joined(separator: ", "),
                    user.provisioningAllowed ? "YES" : "NO",
                    user.allAppsVisible ? "YES" : "NO",
                    user.visibleApps?.joined(separator: ", ") ?? ""
                ])
            }

            let str = table.render()

            print(str)
        }
    }
}

private func getMockUsers() -> [User] {
    let one = User(username: "chris.kolbu", firstName: "Chris", lastName: "Kolbu", roles: [.appManager, .sales], provisioningAllowed: true, allAppsVisible: false, visibleApps: ["com.ittybittyapps.app1"])
    let two = User(username: "other.user", firstName: "Awkward", lastName: "Aardvark", roles: [.accountHolder, .developer], provisioningAllowed: true, allAppsVisible: true, visibleApps: ["*"])
    return [one, two]
}
