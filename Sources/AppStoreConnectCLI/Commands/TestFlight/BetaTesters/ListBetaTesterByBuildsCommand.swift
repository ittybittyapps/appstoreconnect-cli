// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTesterByBuildsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "listByBuilds",
        abstract: "List beta testers who were specifically assigned to one or more builds"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    @Option(
        parsing: .upToNextOption,
        help: "The pre-release version number of this build. (eg. 1.0.0)"
    )
    var preReleaseVersions: [String]

    @Option(
        parsing: .upToNextOption,
        help: "The version number of this build. (eg. 1)"
    )
    var versions: [String]

    func run() throws {
        let api = try makeClient()

        _  = api
            .getAppResourceIdsFrom(bundleIds: [bundleId])
            .flatMap { [versions, preReleaseVersions] appIds -> AnyPublisher<BuildsResponse, Error> in
                var filters: [ListBuilds.Filter] = [.app(appIds)]

                if !versions.isEmpty {
                    filters.append(.version(versions))
                }

                if !preReleaseVersions.isEmpty {
                    filters.append(.version(preReleaseVersions))
                }

                return api.request(APIEndpoint.builds(filter: filters))
                    .eraseToAnyPublisher()
            }
            .flatMap {
                api.request(APIEndpoint.betaTesters(
                        filter: [.builds($0.data.map(\.id))],
                        include: [.apps, .betaGroups]
                    )
                )
            }
            .map { response in
                response.data.map { BetaTester.init($0, response.included) }
            }
            .renderResult(format: common.outputFormat)
    }

}
