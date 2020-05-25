// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBetaTesterByBuildsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "listbybuilds",
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

    private enum CommandError: LocalizedError {
        case noBuildsFound(preReleaseVersions: [String], versions: [String])

        var failureReason: String? {
            switch self {
            case .noBuildsFound(let preReleaseVersions, let versions):
                return "No builds were found matching preReleaseVersions \(preReleaseVersions) and versions \(versions)"
            }
        }
    }

    func run() throws {
        let service = try makeService()

        let betaTesters = try service
            .getAppResourceIdsFrom(bundleIds: [bundleId])
            .flatMap { [versions, preReleaseVersions] appIds -> AnyPublisher<BuildsResponse, Error> in

                var filters: [ListBuilds.Filter] = [.app(appIds)]

                if !versions.isEmpty {
                    filters.append(.version(versions))
                }

                if !preReleaseVersions.isEmpty {
                    filters.append(.preReleaseVersionVersion(preReleaseVersions))
                }

                return service.request(APIEndpoint.builds(filter: filters))
                    .eraseToAnyPublisher()
            }
            .flatMap { [versions, preReleaseVersions] buildResponse -> AnyPublisher<BetaTestersResponse, Error> in
                guard !buildResponse.data.isEmpty else {
                    let error = CommandError.noBuildsFound(preReleaseVersions: preReleaseVersions, versions: versions)
                    return Fail(error: error as Error).eraseToAnyPublisher()
                }

                let endpoint = APIEndpoint.betaTesters(filter: [.builds(buildResponse.data.map(\.id))],
                                                       include: [.apps, .betaGroups])

                return service.request(endpoint).eraseToAnyPublisher()
            }
            .map { response in
                response.data.map {
                    BetaTester(
                        .init(betaTester: $0,
                              includes: response.included)
                    )
                }
            }
            .await()

        betaTesters.render(format: common.outputFormat)
    }

}
