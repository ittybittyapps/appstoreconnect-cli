// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import CodableCSV
import Combine
import Foundation
import Yams

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
        if dryRun {
            print("## Dry run ##")
        }

        let usersInFile = Readers.FileReader<[User]>(format: inputFormat).read(filePath: config)

        let service = try makeService()

        let result = usersInAppStoreConnect(service)
            .flatMap { users -> AnyPublisher<UserChange, Error> in
                let changes = usersInFile.difference(from: users) { lhs, rhs -> Bool in
                    lhs.username == rhs.username
                }

                if self.dryRun {
                    return Publishers.Sequence(sequence: changes)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return self.sync(users: changes, service: service)
                        .eraseToAnyPublisher()
                }
            }
            .awaitResult()

        result.render(format: common.outputFormat)
    }

    private func sync(users changes: CollectionDifference<User>, service: AppStoreConnectService) -> AnyPublisher<UserChange, Error> {
        let requests = changes
            .compactMap { change -> AnyPublisher<UserChange, Error>? in
                switch change {
                case .insert(_, let user, _):
                    return service
                        .request(APIEndpoint.invite(user: user))
                        .map { _ in change }
                        .eraseToAnyPublisher()

                case .remove(_, let user, _):
                    let removeUser = { service.request(APIEndpoint.remove(userWithId: $0)) }

                    return service
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
