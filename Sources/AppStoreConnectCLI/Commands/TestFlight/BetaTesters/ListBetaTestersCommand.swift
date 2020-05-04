// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTestersCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List beta testers")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "The bundle ID of an application. (eg. com.example.app)")
    var filterBundleId: String?

    @Option(help: "The name of the beta group")
    var filterGroupName: String?

    @Option(default: 10,
            help: "Number of included related resources to return.")
    var relatedResourcesLimit: Int

    private enum ListBetaTesterError: LocalizedError {
        case multipleFilters

        var failureReason: String? {
            switch self {
                case .multipleFilters:
                    return "Only one relationship filter can be applied"
            }
        }
    }

    private enum ListStrategy {
        case all
        case listByApp(bundleId: String)
        case listByGroup(betaGroupName: String)
        case listByAppAndGroup

        typealias ListOptions = (bundleId: String?, betaGroupName: String?)

        init(options: ListOptions) {
            switch (options.bundleId, options.betaGroupName) {
                case let(.some(bundleId), .some(betaGroup)) where !bundleId.isEmpty && !betaGroup.isEmpty:
                    self = .listByAppAndGroup
                case let(.some(bundleId), _) where !bundleId.isEmpty:
                    self = .listByApp(bundleId: bundleId)
                case let(_, .some(betaGroupName)) where !betaGroupName.isEmpty:
                    self = .listByGroup(betaGroupName: betaGroupName)
                case (_, _):
                    self = .all
            }
        }
    }

    func run() throws {
        let api = try makeService()

        let request: AnyPublisher<BetaTestersResponse, Error>

        let includes = [ListBetaTesters.Include.apps, ListBetaTesters.Include.betaGroups]
        let limits = [ListBetaTesters.Limit.apps(relatedResourcesLimit),
                      ListBetaTesters.Limit.betaGroups(relatedResourcesLimit)]

        switch ListStrategy(options: (filterBundleId, filterGroupName)) {
            case .all:
                request = api
                    .request(APIEndpoint.betaTesters(include: includes, limit: limits))
                    .eraseToAnyPublisher()
            case .listByApp(let bundleId):
                request = api
                    .getAppResourceIdsFrom(bundleIds: [bundleId])
                    .flatMap {
                        api.request(APIEndpoint.betaTesters(
                            filter: [.apps($0)],
                            include: includes,
                            limit: limits
                        ))
                    }
                    .eraseToAnyPublisher()
            case .listByGroup(let betaGroupName):
                request = api.betaGroupIdentifier(matching: betaGroupName)
                    .flatMap {
                        api.request(APIEndpoint.betaTesters(
                            filter: [.betaGroups([$0])],
                            include: includes,
                            limit: limits
                        ))
                    }
                    .eraseToAnyPublisher()
            case .listByAppAndGroup:
                request = Fail(error: ListBetaTesterError.multipleFilters)
                    .eraseToAnyPublisher()
        }

        let betaTesters = try request
            .map { response in
                response.data.map {
                    BetaTester(.init(betaTester: $0,
                              includes: response.included)
                    )
                }
            }
            .await()

        betaTesters.render(format: common.outputFormat)
    }
}
