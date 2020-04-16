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

    private enum ListStrategy {
        case all
        case listByApp(bundleId: String)
        case listByGroup(betaGroupName: String)

        typealias ListOptions = (bundleId: String?, betaGroupName: String?)

        init(options: ListOptions) {
            switch (options.bundleId, options.betaGroupName) {
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
        let api = try makeClient()

        let request: AnyPublisher<BetaTestersResponse, Error>

        let includes = [ListBetaTesters.Include.apps, ListBetaTesters.Include.betaGroups]

        switch ListStrategy(options: (filterBundleId, filterGroupName)) {
            case .all:
                request = api
                    .request(APIEndpoint.betaTesters(include: includes))
                    .eraseToAnyPublisher()

            case .listByApp(let bundleId):
                request = api
                    .getAppResourceIdsFrom(bundleIds: [bundleId])
                    .flatMap {
                        api.request(APIEndpoint.betaTesters(
                            filter: [ListBetaTesters.Filter.apps($0)],
                            include: includes
                        ))
                    }
                    .eraseToAnyPublisher()

            case .listByGroup(let betaGroupName):
                request = try api.betaGroupIdentifier(matching: betaGroupName)
                    .flatMap {
                        api.request(APIEndpoint.betaTesters(
                            filter: [ListBetaTesters.Filter.betaGroups([$0])],
                            include: includes
                        ))
                    }
                    .eraseToAnyPublisher()
        }

        _ = request
            .map { response in
                response.data.map { BetaTester.init($0, response.included) }
            }
            .renderResult(format: common.outputFormat)
    }
}
