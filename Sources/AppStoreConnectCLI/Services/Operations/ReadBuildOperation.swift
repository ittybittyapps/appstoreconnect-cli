//
//  ReadBuildOperation.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Nafisa Rahman on 1/5/20.
//
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBuildOperation {
  private let options: ReadBuildOptions

  private var listFilters: [ListBuilds.Filter]? {
    var filters = [ListBuilds.Filter]()

    if options.preReleaseVersion.isEmpty == false {
      filters += [ListBuilds.Filter.preReleaseVersionVersion(options.preReleaseVersion)]
    }

    if options.buildNumber.isEmpty == false {
      filters += [ListBuilds.Filter.version(options.buildNumber)]
    }

    return filters
  }

  private enum ReadBuildError: LocalizedError {
    case noAppExist
    case noBuildExist
  }

  init(options: ReadBuildOptions) {
    self.options = options
  }

  func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[BuildDetailsInfo], Error> {
      let appIds = try GetAppsOperation(
          options: .init(bundleIds: [options.bundleId])
      )
      .execute(with: requestor)
      .await()
      .map { $0.id }

      guard let appId = appIds.first else {
          throw ReadBuildError.noAppExist
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

      return requestor.request(endpoint)
        .tryMap { (buildResponse) throws -> [BuildDetailsInfo] in
          guard !buildResponse.data.isEmpty else {
              throw ReadBuildError.noBuildExist
           }

          let buildDetailsInfo = buildResponse.data.map {
              BuildDetailsInfo($0, buildResponse.included)
          }

          return buildDetailsInfo
      }
      .eraseToAnyPublisher()
  }
}
