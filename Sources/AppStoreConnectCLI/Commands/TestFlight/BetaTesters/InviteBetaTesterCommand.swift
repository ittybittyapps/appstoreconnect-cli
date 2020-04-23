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

        var errorDescription: String? {
            switch self {
            case .noGroupsExist(let groupNames, let bundleId):
                return "One or more of beta groups \"\(groupNames)\" don't exist or don't belong to application with bundle ID \"\(bundleId)\"."
            }
        }
    }

    func run() throws {
        let service = try makeService()

        let appId = try service.appResourceId(matching: bundleId).await()

        let betaGroups = try service.request(APIEndpoint.betaGroups(forAppWithId: appId)).map { $0.data }.await()

        let groupNamesInApp = Set(betaGroups.compactMap { $0.attributes?.name })
        let inputGroupNames = Set(groups)

        guard inputGroupNames.isSubset(of: groupNamesInApp) else {
            throw CommandError.noGroupsExist(groupNames: groups, bundleId: bundleId)
        }

        let groupIds = try service
            .betaGroupIdentifiers(matching: groups)
            .await()

        let createBetaTesterRequests = groupIds.map {
            service
                .request(
                    APIEndpoint.create(
                        betaTesterWithEmail: email,
                        firstName: firstName,
                        lastName: lastName,
                        betaGroupIds: [$0])
                )
                .eraseToAnyPublisher()
        }

        let testerId = try Publishers
            .ConcatenateMany(createBetaTesterRequests)
            .last()
            .await()
            .data
            .id

        let betaTesterResponse = try service
            .request(
                APIEndpoint.betaTester(
                    withId: testerId,
                    include: [GetBetaTester.Include.betaGroups,
                              GetBetaTester.Include.apps])
            )
            .await()

        let betaTester = BetaTester(betaTesterResponse.data, betaTesterResponse.included)

        betaTester.render(format: common.outputFormat)
    }
}
