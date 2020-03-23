// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

struct CreateBetaTesterCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a beta tester")

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "the beta tester’s email address, used for sending beta testing invitations.")
    var email: String

    @Option(help: "the beta tester’s first name.")
    var firstName: String?

    @Option(help: "the beta tester’s last name.")
    var lastName: String?

    @Argument(help: "array of opaque resource ID that uniquely identifies the resources.")
    var buildIds: [String]

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        let request = APIEndpoint.create(betaTesterWithEmail: email, firstName: firstName, lastName: lastName, buildIds: buildIds)

        _ = api.request(request)
            .map{ $0.data }
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        print(String(describing: error))
                    }
                },
                receiveValue: { (tester: BetaTester) -> Void in
                    print("Invitation has been sent! tester info: ")

                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                    let json = try! jsonEncoder.encode(["betatester": tester])

                    print(String(data: json, encoding: .utf8)!)
                }
            )

    }
}
