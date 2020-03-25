// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Combine
import SwiftyTextTable
import Yams
import AppStoreConnect_Swift_SDK

protocol Renderer {
    associatedtype Input

    func render(_ input: Input)
}

enum Renderers {
    struct CompletionRenderer: Renderer {
        func render(_ input: Subscribers.Completion<Error>) {
            switch input {
                case .finished:
                    print("Completed successfully")
                case .failure(let error):
                    print("Completed with error: \(error)")
            }
        }
    }
}

extension Renderers {
    struct UserRenderer: Renderer {
        typealias Input = User

        let format: OutputFormat?
        let includeVisibleApps: Bool

        func render(_ input: User) {
            var user = input

            if !includeVisibleApps {
                user.visibleApps = []
            }

            switch format ?? .table {
                case .json:
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    let json = try! jsonEncoder.encode(user)

                    print(String(data: json, encoding: .utf8)!)
                case .yaml:
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try! yamlEncoder.encode(user)

                    print(yaml)
                case .table:
                    let columns = User.tableColumns(includeVisibleApps: self.includeVisibleApps)
                    var table = TextTable(columns: columns)
                    table.addRow(values: input.tableRow)

                    print(table.render())
            }
        }
    }
}

extension Renderers {
    struct UserInvitationRenderer: Renderer {
        typealias Input = UserInvitation

        let format: OutputFormat?

        func render(_ input: UserInvitation) {
            print("Invitation email has been sent, invitation info: ")
            
            switch format ?? .table {
                case .json:
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    let data = try! jsonEncoder.encode(input)

                    print(String(data: data, encoding: .utf8)!)
                case .yaml:
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try! yamlEncoder.encode(input)

                    print(yaml)
                case .table:
                    let columns = UserInvitation.tableColumns()
                    var table = TextTable(columns: columns)
                    table.addRow(values: input.tableRow)

                    print(table.render())
            }
        }
    }
}
