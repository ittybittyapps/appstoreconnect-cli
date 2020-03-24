// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import SwiftyTextTable
import Yams
import AppStoreConnect_Swift_SDK

struct UserInvitationOutput {
    let userInvitation: UserInvitation
    var format: OutputFormat

    init(userInvitation: UserInvitation, format: OutputFormat?) {
        self.userInvitation = userInvitation
        self.format = format ?? .table
    }
}

extension UserInvitationOutput: CustomStringConvertible {
    var description: String {
        let formatInvitation: (UserInvitation) throws -> String

        switch format {
            case .json:
                formatInvitation = { invitation in
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                    let data = try! jsonEncoder.encode(invitation)
                    return String(data: data, encoding: .utf8)!
                }
            case .yaml:
                formatInvitation = { invitation in
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try yamlEncoder.encode(invitation)
                    return "invitation:\n" + yaml
                }
            case .table:
                formatInvitation = { invitation in
                    let columns = UserInvitation.tableColumns()
                    var table = TextTable(columns: columns)
                    table.addRow(values: invitation.tableRow)

                    return table.render()
                }
        }
        do {
            return try formatInvitation(userInvitation)
        } catch {
            return "Failed to format users"
        }
    }
}

extension UserInvitation {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Email"),
            TextTableColumn(header: "First Name"),
            TextTableColumn(header: "Last Name"),
            TextTableColumn(header: "Roles"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Provisioning Allowed"),
            TextTableColumn(header: "All Apps Visible")
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            attributes?.email ?? "",
            attributes?.firstName ?? "",
            attributes?.lastName ?? "",
            attributes?.roles?.map { $0.rawValue }.joined(separator: ", ") ?? "",
            attributes?.expirationDate ?? "",
            attributes?.provisioningAllowed?.toYesNo() ?? "",
            attributes?.allAppsVisible?.toYesNo() ?? ""
        ]
    }
}
