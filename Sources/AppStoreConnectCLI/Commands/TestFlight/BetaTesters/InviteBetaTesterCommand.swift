// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct InviteBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "invite",
        abstract: "Invite a beta tester and assign them to one or more groups")

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

    private enum CommandError: LocalizedError {
        case noGroupsExist(groupNames: [String], bundleId: String)

        var failureReason: String? {
            switch self {
            case .noGroupsExist(let groupNames, let bundleId):
                return "One or more of beta groups \"\(groupNames)\" don't exist or don't belong to application with bundle ID \"\(bundleId)\"."
            }
        }
    }

    func run() throws {
        let service = try makeService()

        _ = api
            .appResourceId(matching: bundleId)
            .flatMap {
                api.request(APIEndpoint.betaGroups(forAppWithId: $0))
            }
            // Check if input group names are belong to the app
            .flatMap { [groups, bundleId] (response) -> AnyPublisher<[String], Error> in
                let groupNamesInApp = Set(response.data.compactMap { $0.attributes?.name })
                let inputGroupNames = Set(groups)

                guard inputGroupNames.isSubset(of: groupNamesInApp) else {
                    let error = CommandError.noGroupsExist(groupNames: groups, bundleId: bundleId)
                    return Fail(error: error).eraseToAnyPublisher()
                }

                return api.betaGroupIdentifiers(matching: groups)
            }
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

                return Publishers.ConcatenateMany(requests)
                    .last()
                    .eraseToAnyPublisher()
            }
            // Get invited tester info
            .flatMap {
                api.request(APIEndpoint.betaTester(
                        withId: $0.data.id,
                        include: [GetBetaTester.Include.betaGroups,
                                  GetBetaTester.Include.apps]
                    ))
                    .eraseToAnyPublisher()
            }
            .map { BetaTester($0.data, $0.included) }
            .renderResult(format: common.outputFormat)
    }
}
