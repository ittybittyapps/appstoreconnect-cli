// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import SwiftyTextTable
import Yams

protocol UserOutputBuilder {
    var includeVisibleApps: Bool { get }
    var outputFormat: OutputFormat? { get }
}

extension UserOutputBuilder {
    func output(_ users: [User], includeVisibleApps: Bool) {
        if let outputFormat = outputFormat {
            do {
                switch outputFormat {
                    case .json:
                        let jsonEncoder = JSONEncoder()
                        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                        let redactedUsers = includeVisibleApps
                            ? users
                            : users.map { user in
                                var copy = user
                                copy.visibleApps = nil
                                return copy
                        }

                        var dict = [String:[User]]()
                        dict["users"] = redactedUsers
                        let json = try jsonEncoder.encode(dict)
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
            let columns = User.tableColumns(includeVisibleApps: includeVisibleApps)
            var table = TextTable(columns: columns)
            table.addRows(values: users.map { $0.tableRow })
            let str = table.render()

            print(str)
        }
    }
}
