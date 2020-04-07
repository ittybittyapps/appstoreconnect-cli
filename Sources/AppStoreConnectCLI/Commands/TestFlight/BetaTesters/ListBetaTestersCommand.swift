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
    var bundleId: String

    @Option(default: "",
            help: "The name of the beta group")
    var betaGroupName: String

    @Option(default: "",
            help: "The ID of one build of an application")
    var buildId: String

    private enum ListStrategy {
        case all
        case listByApp(bundleId: String)
        case listByGroup(betaGroupName: String)
        case listByBuild(buildId: String)

        init(_ bundleId: String, _ betaGroupName: String, _ buildId: String) {
            switch (bundleId, betaGroupName, buildId) {
                case (let bundleId, _, _) where !bundleId.isEmpty:
                    self = .listByApp(bundleId: bundleId)
                case (_, let betaGroupName, _) where !betaGroupName.isEmpty:
                    self = .listByGroup(betaGroupName: betaGroupName)
                case (_, _, let buildId) where !buildId.isEmpty:
                    self = .listByBuild(buildId: buildId)
                case (_, _, _):
                    self = .all
            }
        }
    }

    func run() throws {
        let api = try makeClient()

        let request: AnyPublisher<BetaTestersResponse, Error>

        switch ListStrategy(bundleId, betaGroupName, buildId) {
            case .all:
                request = api.request(APIEndpoint.betaTesters()).eraseToAnyPublisher()

            case .listByApp(let bundleId):
                request = api
                    .getAppResourceIdsFrom(bundleIds: [bundleId])
                    .flatMap {
                        api.request(APIEndpoint.betaTesters(
                            filter: [ListBetaTesters.Filter.apps($0)]
                        ))
                    }
                    .eraseToAnyPublisher()
            case .listByGroup(let betaGroupName):
                request = try api.betaGroupIdentifier(matching: betaGroupName)
                    .flatMap {
                        api.request(APIEndpoint.betaTesters(
                            filter: [ListBetaTesters.Filter.betaGroups([$0])])
                        )
                    }
                    .eraseToAnyPublisher()
            case .listByBuild(let buildId):
                request = api.request(APIEndpoint.betaTesters(
                    filter: [ListBetaTesters.Filter.builds([buildId])]
                    ))
                    .eraseToAnyPublisher()

        }

        _ = request
            .map(\.data)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
