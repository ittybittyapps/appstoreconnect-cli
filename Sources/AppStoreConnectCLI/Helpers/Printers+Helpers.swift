// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Combine
import SwiftyTextTable
import Yams
import AppStoreConnect_Swift_SDK

protocol Printer {
    associatedtype Input

    func print(_ input: Input)
}

enum Printers {
    struct CompletionPrinter: Printer {
        func print(_ input: Subscribers.Completion<Error>) {
            switch input {
                case .finished:
                    Swift.print("Completed successfully")
                case .failure(let error):
                    Swift.print("Completed with error: \(error)")
            }
        }
    }
}

extension Printers {
    struct UserPrinter: Printer {
        typealias Input = User

        let format: OutputFormat?
        let includeVisibleApps: Bool

        func print(_ input: User) {
            switch format ?? .table {
                case .json:
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                    var user = input

                    if !self.includeVisibleApps {
                        user.visibleApps = []
                    }

                    let json = try! jsonEncoder.encode(user)

                    Swift.print(String(data: json, encoding: .utf8)!)
                case .yaml:
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try! yamlEncoder.encode(input)

                    Swift.print("User Info:\n" + yaml)
                case .table:
                    let columns = User.tableColumns(includeVisibleApps: self.includeVisibleApps)
                    var table = TextTable(columns: columns)
                    table.addRow(values: input.tableRow)

                    Swift.print(table.render())
            }
        }
    }
}

extension Printers {
    struct UserInvitationOutput: Printer {
        typealias Input = UserInvitation

        let format: OutputFormat?

        func print(_ input: UserInvitation) {
            Swift.print("Invitation email has been sent, invitation info: ")
            
            switch format ?? .table {
                case .json:
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    let data = try! jsonEncoder.encode(input)

                    Swift.print(String(data: data, encoding: .utf8)!)
                case .yaml:
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try! yamlEncoder.encode(input)

                    Swift.print("invitation:\n" + yaml)
                case .table:
                    let columns = UserInvitation.tableColumns()
                    var table = TextTable(columns: columns)
                    table.addRow(values: input.tableRow)

                    Swift.print(table.render())
            }
        }
    }
}
