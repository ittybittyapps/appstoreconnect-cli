// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import SwiftyTextTable
import Yams

struct UserOutput {
    let users: [User]
    let includeVisibleApps: Bool
    let format: OutputFormat?
}

extension UserOutput: CustomStringConvertible {
    var description: String {
        if let outputFormat = format {
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
                        return(String(data: json, encoding: .utf8)!)
                    case .yaml:
                        let yamlEncoder = YAMLEncoder()
                        let yaml = try yamlEncoder.encode(users)
                        return("users:\n" + yaml)
                }
            } catch {
                return "Error \(error.localizedDescription)"
            }
        } else {
            let columns = User.tableColumns(includeVisibleApps: includeVisibleApps)
            var table = TextTable(columns: columns)
            table.addRows(values: users.map { $0.tableRow })
            let str = table.render()
            
            return(str)
        }
    }
}
