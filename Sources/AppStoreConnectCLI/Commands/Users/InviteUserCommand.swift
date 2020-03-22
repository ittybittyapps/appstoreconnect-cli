// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

//extension Array: ExpressibleByArgument where Element == String {
//    public init?(argument: String) {
//        self = [argument]
//    }
//}

struct InviteUserCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a user with assigned user roles to join your team.")

    @Option(default: "../config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "The email address of a pending user invitation. The email address must be valid to activate the account. It can be any email address, not necessarily one associated with an Apple ID.")
    var email: String

    @Argument(help: "The user invitation recipient's first name.")
    var firstName: String

    @Argument(help: "The user invitation recipient's last name.")
    var lastName: String

    @Argument(help: "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.")
    var roles: [UserRole]

    @Flag(help: "Indicates that a user has access to all apps available to the team.")
    var allAppsVisible: Bool

    @Flag(help: "Indicates the user's specified role allows access to the provisioning functionality on the Apple Developer website.")
    var provisioningAllowed: Bool

    //TODO: parse two arrays as argument
//    @Argument(help: "Array of opaque resource ID that uniquely identifies the resources.")
//    var appsVisibleIds: [String]

    public func run() throws {
        let api = try HTTPClient(auth: auth)

        let request = APIEndpoint.invite(userWithEmail: email,
                                         firstName: firstName,
                                         lastName: lastName,
                                         roles: roles,
                                         allAppsVisible: allAppsVisible,
                                         provisioningAllowed: provisioningAllowed,
                                         appsVisibleIds: nil)

        _ = api.request(request)
            .map { $0.data }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print(String(describing: error))
                }
            }, receiveValue: { (result: UserInvitation) -> Void in
                print("Invitation email has been sent, invitation info: ")

                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                let data = try! jsonEncoder.encode(result)
                print(String(data: data, encoding: .utf8)!)
            }
        )
    }
}
