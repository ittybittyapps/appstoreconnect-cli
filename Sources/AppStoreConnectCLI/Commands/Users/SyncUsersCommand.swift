// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import CodableCSV
import Combine
import Foundation
import Yams

struct SyncUsersCommand: ParsableCommand {

    enum Operation {
        /// Don't do anything with this User
        case ignore(username: String)

        /// Add user to UserInvitations resource
        case invite(User)

        /// Remove the user from Users resource
        case remove(username: String)

        /// Remove the user from UserInvitations resource
        case uninvite(username: String)
    }

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

        let client = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        _ = Publishers
            .CombineLatest(
                usersInAppStoreConnect(client),
                invitationsInAppStoreConnect(client)
            )
            .map(changeOperations(existingUsers:pendingInvites:))
            .flatMap { changes -> AnyPublisher<Operation, Error> in
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

    private func changeOperations(existingUsers: [User], pendingInvites: [UserInvitation]) -> [Operation] {
        let usersInFile = Readers.FileReader<[User]>(format: inputFormat).read(filePath: config)

        let newInvites = usersInFile.map { user -> Operation in
            if existingUsers.contains(where: { $0.username == user.username} ) ||
                pendingInvites.contains(where: { $0.attributes?.email == user.username} ) {
                // user exists in API and in input file
                return .ignore(username: user.username)
            } else {
                // not in API or pending invitation, and in input file
                return .invite(user)
            }
        }

        let removals = existingUsers
            .filter { user in
                // user not in input file, but is in API list of users
                usersInFile.contains(where: { $0.username == user.username }) == false
            }.map {
                Operation.remove(username: $0.username)
            }

        let uninvites = pendingInvites
            .filter { invitation in
                // user not in input file, but is in API list of invitations
                usersInFile.contains(where: { $0.username == invitation.attributes?.email }) == false
            }.compactMap {
                $0.attributes?.email.map { Operation.uninvite(username: $0) }
            }

        return newInvites + removals + uninvites
    }

    private func sync(users operations: [Operation], client: HTTPClient) -> AnyPublisher<Operation, Error> {
        let requests = operations
            .compactMap { operation -> AnyPublisher<Operation, Error>? in
                switch operation {
                case .ignore:
                    return Just(operation)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()

                case .invite(let user):
                    return client
                        .request(APIEndpoint.invite(user: user))
                        .map { _ in operation }
                        .eraseToAnyPublisher()

                case .remove(let username):
                    let removeUser = { client.request(APIEndpoint.remove(userWithId: $0)) }

                    return client
                        .userIdentifier(matching: username)
                        .flatMap(removeUser)
                        .map { _ in operation }
                        .eraseToAnyPublisher()

                case .uninvite(let username):
                    let uninviteUser = { client.request(APIEndpoint.cancel(userInvitationWithId: $0)) }

                    return client
                        .invitationIdentifier(matching: username)
                        .flatMap(uninviteUser)
                        .map { _ in operation }
                        .eraseToAnyPublisher()
                }
            }

        return Publishers.ConcatenateMany(requests).eraseToAnyPublisher()
    }

    private func usersInAppStoreConnect(_ client: HTTPClient) -> AnyPublisher<[User], Error> {
        client
            .request(.users())
            .map(User.fromAPIResponse)
            .eraseToAnyPublisher()
    }

    private func invitationsInAppStoreConnect(_ client: HTTPClient) -> AnyPublisher<[UserInvitation], Error> {
        client
            .request(.invitedUsers())
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

private extension Renderers {

    struct UserChangesRenderer: Renderer {
        let dryRun: Bool

        func render(_ input: SyncUsersCommand.Operation) {
            switch input {
            case .ignore(let username):
                print("ignored \(username)")
            case .invite(let user):
                print("invited \(user.username)")
            case .remove(let username):
                print("removed \(username)")
            case .uninvite(let username):
                print("uninvited \(username)")
            }
        }
    }
}
