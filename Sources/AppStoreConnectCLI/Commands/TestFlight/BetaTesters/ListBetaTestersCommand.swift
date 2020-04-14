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

    @Option(default: "",
            help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String?

    @Option(default: "",
            help: "The name of the beta group")
    var betaGroupName: String?

    @Option(default: "",
            help: "The ID of one build of an application")
    var buildId: String?

    private enum ListStrategy {
        case all
        case listByApp(bundleId: String)
        case listByGroup(betaGroupName: String)
        case listByBuild(buildId: String)

        typealias ListOptions = (bundleId: String?, betaGroupName: String?, buildId: String?)

        init(options: ListOptions) {
            switch (options.bundleId, options.betaGroupName, options.buildId) {
                case let(.some(bundleId), _, _) where !bundleId.isEmpty:
                    self = .listByApp(bundleId: bundleId)
                case let(_, .some(betaGroupName), _) where !betaGroupName.isEmpty:
                    self = .listByGroup(betaGroupName: betaGroupName)
                case let(_, _, .some(buildId)) where !buildId.isEmpty:
                    self = .listByBuild(buildId: buildId)
                case (_, _, _):
                    self = .all
            }
        }
    }

    func run() throws {
        let api = try makeClient()

        let request: AnyPublisher<BetaTestersResponse, Error>

        let includes = [ListBetaTesters.Include.apps, ListBetaTesters.Include.betaGroups]

        switch ListStrategy(options: (bundleId, betaGroupName, buildId)) {
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
            
            case .listByBuild(let buildId):
                request = api.request(APIEndpoint.betaTesters(
                        filter: [ListBetaTesters.Filter.builds([buildId])],
                        include: includes
                    ))
                    .eraseToAnyPublisher()
        }

        _ = request
            .map(\.data)
            .flatMap { api.fromAPIBetaTesters(betaTesters: $0) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
