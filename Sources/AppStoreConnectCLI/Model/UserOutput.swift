// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import SwiftyTextTable
import Yams

struct UserOutput {
    let users: [User]
    let includeVisibleApps: Bool
    var format: OutputFormat

    init(users: [User], includeVisibleApps: Bool, format: OutputFormat?) {
        self.users = users
        self.includeVisibleApps = includeVisibleApps
        self.format = format ?? .table
    }
}

extension UserOutput: CustomStringConvertible {
    var description: String {
        let formatUsers: ([User]) throws -> String
        switch format {
            case .json:
                formatUsers = {
                    var users = $0
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                    if !self.includeVisibleApps {
                        users = users.map { user in
                            var newUser = user
                            newUser.visibleApps = nil
                            return newUser
                        }
                    }

                    let json = try jsonEncoder.encode(["users": users])
                    return String(data: json, encoding: .utf8)!
                }
            case .yaml:
                formatUsers = { users in
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try yamlEncoder.encode(users)
                    return "users:\n" + yaml
                }
            case .table:
                formatUsers = {
                    let columns = User.tableColumns(includeVisibleApps: self.includeVisibleApps)
                    var table = TextTable(columns: columns)
                    table.addRows(values: $0.map { $0.tableRow })
                    return table.render()
                }
        }

        do {
            return try formatUsers(users)
        } catch {
            return "Failed to format users"
        }
    }
}
