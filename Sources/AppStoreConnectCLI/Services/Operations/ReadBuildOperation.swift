// Copyright 2020 Itty Bitty Apps Pty Ltd
//
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBuildOperation: APIOperation {

  struct Options {
    let appId: [String]
    let buildNumber: [String]
    let preReleaseVersion: [String]
  }

  enum ReadBuildError: LocalizedError {
    case noBuildExist

    var errorDescription: String? {
      switch self {
      case .noBuildExist:
        return "No build exists"
      }
    }
  }

  private let options: Options

  init(options: Options) {
    self.options = options
  }

  func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[BuildDetailsInfo], Error> {

    var filters = [ListBuilds.Filter]()

    if options.preReleaseVersion.isEmpty == false {
      filters += [ListBuilds.Filter.preReleaseVersionVersion(options.preReleaseVersion)]
    }

    if options.buildNumber.isEmpty == false {
      filters += [ListBuilds.Filter.version(options.buildNumber)]
    }

    filters += [ListBuilds.Filter.app(options.appId)]

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
