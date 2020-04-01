// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import CodableCSV
import Combine
import Foundation
import Yams

struct SyncUsersCommand: ParsableCommand {
    typealias UserChange = CollectionDifference<User>.Change

    static var configuration = CommandConfiguration(
        commandName: "sync",
        abstract: "Sync information about users on your team with provided configuration file."
    )

    @OptionGroup()
    var authOptions: AuthOptions

    @Argument(help: "Path to the file containing the information about users. Specify format with --input-format")
    var config: String

    @Option(
        default: .json,
        help: "Read config file in provided format (\(InputFormat.allCases.map { $0.rawValue }.joined(separator: ", ")))."
    )
    var inputFormat: InputFormat

    @Flag(help: "Perform a dry run.")
    var dryRun: Bool

    func run() throws {
        if dryRun {
            print("## Dry run ##")
        }

        let usersInFile = try readUsers(from: config)
        let client = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        _ = usersInAppStoreConnect(client)
            .flatMap { users -> AnyPublisher<UserChange, Error> in
                let changes = usersInFile.difference(from: users) { lhs, rhs -> Bool in
                    lhs.username == rhs.username
                }

                if self.dryRun {
                    return Publishers.Sequence(sequence: changes)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return self.sync(users: changes, client: client)
                        .eraseToAnyPublisher()
                }
            }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.UserChangesRenderer(dryRun: dryRun).render
            )
    }

    private func sync(users changes: CollectionDifference<User>, client: HTTPClient) -> AnyPublisher<UserChange, Error> {
        let invitationRequests = changes
            .compactMap { change -> AnyPublisher<UserChange, Error>? in
                guard case .insert(_, let user, _) = change else {
                    return nil
                }

                return client
                    .request(APIEndpoint.invite(user: user))
                    .map { _ in change }
                    .eraseToAnyPublisher()
            }

        return Publishers.ConcatenateMany(invitationRequests).eraseToAnyPublisher()
    }

    private func readUsers(from filePath: String) throws -> [User] {
        guard let fileContents = try? String(contentsOfFile: config, encoding: .utf8) else {
            fatalError("Could not read file: \(filePath)")
        }

        switch inputFormat {
        case .csv:
            fatalError("CSV not implemented yet")
        case .json:
            guard let data = fileContents.data(using: .utf8) else {
                fatalError("Could not read file contents: \(filePath)")
            }
            return try JSONDecoder().decode([User].self, from: data)
        case .yaml:
            return try YAMLDecoder().decode([User].self, from: fileContents)
        }
    }

    private func usersInAppStoreConnect(_ client: HTTPClient) -> AnyPublisher<[User], Error> {
        client
            .request(.users())
            .map(User.fromAPIResponse)
            .eraseToAnyPublisher()
    }
}

private extension Renderers {
    struct UserChangesRenderer: Renderer {
        let dryRun: Bool

        func render(_ input: SyncUsersCommand.UserChange) {
            switch input {
            case .insert(_, let user, _):
                print("+\(user.username)")
            case .remove(_, let user, _):
                print("-\(user.username)")
            }
        }
    }
}
