// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import struct Model.User
import FileSystem

struct SyncUsersCommand: CommonParsableCommand {
    typealias UserChange = CollectionDifference<User>.Change

    static var configuration = CommandConfiguration(
        commandName: "sync",
        abstract: "Sync information about users on your team with provided configuration file."
    )

    @OptionGroup()
    var common: CommonOptions

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
        // Command output is parsable by default. Only print if user is enabling verbosity or output is a `.table`
        if dryRun, common.verbose || common.outputFormat == .table {
            print("## Dry run ##")
        }

        let usersInFile = Readers.FileReader<[User]>(format: inputFormat).read(filePath: config)

        let client = try makeService()

        let change = try usersInAppStoreConnect(client)
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
            .await()

        Renderers.UserChangesRenderer(dryRun: dryRun).render(change)
    }

    private func sync(users changes: CollectionDifference<User>, client: AppStoreConnectService) -> AnyPublisher<UserChange, Error> {
        let requests = changes
            .compactMap { change -> AnyPublisher<UserChange, Error>? in
                switch change {
                case .insert(_, let user, _):
                    return client
                        .request(APIEndpoint.invite(user: user))
                        .map { _ in change }
                        .eraseToAnyPublisher()

                case .remove(_, let user, _):
                    let removeUser = { client.request(APIEndpoint.remove(userWithId: $0)) }

                    return client
                        .userIdentifier(matching: user.username)
                        .flatMap(removeUser)
                        .map { _ in change }
                        .eraseToAnyPublisher()
                }
            }

        return Publishers.ConcatenateMany(requests).eraseToAnyPublisher()
    }

    private func usersInAppStoreConnect(_ client: AppStoreConnectService) -> AnyPublisher<[User], Error> {
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
