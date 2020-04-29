// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBuildCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information about a specific build.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "An opaque resource ID that uniquely identifies the build")
    var bundleId: String

    @Option(
      parsing: .upToNextOption,
      help: "The build number of this build"
    )
    var buildNumber: [String]

    @Option(
      parsing: .upToNextOption,
      help: "The pre-release version number of this build"
    )
    var preReleaseVersion: [String]

    private var listFilters: [ListBuilds.Filter]? {
      var filters = [ListBuilds.Filter]()

      if preReleaseVersion.isEmpty == false {
        filters += [ListBuilds.Filter.preReleaseVersionVersion(preReleaseVersion)]
      }

      if buildNumber.isEmpty == false {
        filters += [ListBuilds.Filter.version(buildNumber)]
      }

      return filters
    }

    func run() throws {
        let service = try makeService()

        let buildResponse = try service
        .getAppResourceIdsFrom(bundleIds: [bundleId])
        .flatMap {(resoureceIds: [String]) -> AnyPublisher<BuildsResponse, Error> in
            guard let appId = resoureceIds.first else {
                fatalError("Can't find a related app with input bundleID")
            }

            var filters: [ListBuilds.Filter] = []
            filters += [ListBuilds.Filter.app([appId])]

            if let listFilters = self.listFilters {
              if listFilters.isEmpty == false {
                filters += listFilters
              }
            }

            let endpoint = APIEndpoint.builds(
              filter: filters,
              include: [.app, .betaAppReviewSubmission, .buildBetaDetail, .preReleaseVersion]
            )

            return service.request(endpoint).eraseToAnyPublisher()
        }
        .await()

        let buildDetailsInfo = buildResponse.data.map {
          BuildDetailsInfo($0, buildResponse.included)
        }

        buildDetailsInfo.render(format: common.outputFormat)
    }
}
