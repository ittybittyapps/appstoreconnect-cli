// Copyright 2020 Itty Bitty Apps Pty Ltd
//
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBuildOperation: APIOperation {

  struct Options {
    let appId: String
    let buildNumber: String
    let preReleaseVersion: String
  }

  enum ReadBuildError: LocalizedError {
    case noBuildExist
    case buildNotUnique

    var errorDescription: String? {
      switch self {
      case .noBuildExist:
        return "No build exists"
      case .buildNotUnique:
      return "More than 1 build returned"
      }
    }
  }

  struct Output {
    let build: AppStoreConnect_Swift_SDK.Build
    let relationships: [AppStoreConnect_Swift_SDK.BuildRelationship]?
  }

  private let options: Options

  init(options: Options) {
    self.options = options
  }

  func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Error> {

    var filters = [ListBuilds.Filter]()

    if options.preReleaseVersion.isEmpty == false {
      filters += [ListBuilds.Filter.preReleaseVersionVersion([options.preReleaseVersion])]
    }

    if options.buildNumber.isEmpty == false {
      filters += [ListBuilds.Filter.version([options.buildNumber])]
    }

    if options.appId.isEmpty == false {
      filters += [ListBuilds.Filter.app([options.appId])]
    }

    let endpoint = APIEndpoint.builds(
      filter: filters,
      include: [.app, .betaAppReviewSubmission, .buildBetaDetail, .preReleaseVersion]
    )

    return requestor.request(endpoint)
      .tryMap { (buildResponse) throws -> Output in
        switch buildResponse.data.count {
        case 0:
          throw ReadBuildError.noBuildExist
        case 1:
          return Output(build: buildResponse.data.first!, relationships: buildResponse.included)
        default:
          throw ReadBuildError.buildNotUnique
        }
    }
    .eraseToAnyPublisher()
  }
}
