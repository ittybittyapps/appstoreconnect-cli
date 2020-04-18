// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Create a beta tester and assign to a group")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The beta tester's email address, used for sending beta testing invitations.")
    var email: String

    @Argument(help: "The beta tester's first name.")
    var firstName: String?

    @Argument(help: "The beta tester's last name.")
    var lastName: String?

    @Argument(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    @Option(parsing: .upToNextOption,
            help: "Names of TestFlight beta tester group that the tester will be assigned to")
    var groups: [String]

    enum CommandError: LocalizedError {
        case noGroupsExist(groupNames: [String], bundleId: String)

        var failureReason: String? {
            switch self {
                case .noGroupsExist(let groupNames, let bundleId):
                    return "One or more of beta groups \"\(groupNames)\" don't exist or don't belongs to application with Bundle ID \"\(bundleId)\"."
            }
        }
    }

    func run() throws {
        let api = try makeClient()

        _ = api
            // Find app resource id matching bundleId
            .appResourceId(matching: bundleId)
            // Find beta groups matching app resource Id
            .flatMap {
                api.request(APIEndpoint.betaGroups(forAppWithId: $0)).eraseToAnyPublisher()
            }
            // Check if input group names are belong to the app, else throw Error
            .tryMap { [groups, bundleId] (response: BetaGroupsResponse) -> AnyPublisher<[String], Error> in
                let groupNamesInApp = Set(response.data.compactMap { $0.attributes?.name })
                let inputGroupNames = Set(groups)

                guard inputGroupNames.isSubset(of: groupNamesInApp) else {
                    throw CommandError.noGroupsExist(groupNames: groups, bundleId: bundleId)
                }

                return try api.betaGroupIdentifiers(matching: groups)
            }
            .flatMap { $0 }
            // Invite tester to the input groups
            .flatMap { [email, firstName, lastName] (groupIds: [String]) -> AnyPublisher<BetaTesterResponse, Error> in
                // A tester can only be invite to one group at a time
                let requests = groupIds.map { (groupId: String) -> AnyPublisher<BetaTesterResponse, Error> in
                    let endpoint = APIEndpoint.create(betaTesterWithEmail: email,
                                                      firstName: firstName,
                                                      lastName: lastName,
                                                      betaGroupIds: [groupId])
                    return api.request(endpoint).eraseToAnyPublisher()
                }

                return Publishers.ConcatenateMany(requests).last().eraseToAnyPublisher()
            }
            // Get invited tester info
            .flatMap {
                api.request(APIEndpoint.betaTester(
                        withId: $0.data.id,
                        include: [GetBetaTester.Include.betaGroups, GetBetaTester.Include.apps]
                    ))
                    .eraseToAnyPublisher()
            }
            .map { BetaTester.init($0.data, $0.included) }
            .renderResult(format: common.outputFormat)
    }
}
