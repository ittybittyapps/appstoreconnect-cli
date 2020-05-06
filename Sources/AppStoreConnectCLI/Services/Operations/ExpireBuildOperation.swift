// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ExpireBuildOperation: APIOperation {

  struct Options {
    let buildId: String?
    let expired: Bool
  }

  enum ExpireBuildError: LocalizedError {
    case noBuildIdFound
    case noBuildExist

    var errorDescription: String? {
      switch self {
      case .noBuildExist:
        return "No build exists"
      case .noBuildIdFound:
        return " No build id found"
      }
    }
  }

  private let options: Options

  init(options: Options) {
    self.options = options
  }

  func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Void, Error> {

    guard self.options.buildId != nil else {
      throw ExpireBuildError.noBuildIdFound
    }

    let buildModifyEndpoint = APIEndpoint.modify(
      buildWithId: self.options.buildId!,
      appEncryptionDeclarationId: "",
      expired: self.options.expired,
      usesNonExemptEncryption: nil)

    return requestor.request(buildModifyEndpoint)
      .tryMap { (buildResponse) throws in

        guard (buildResponse.data.attributes != nil) else {
          throw ExpireBuildError.noBuildExist
        }
    }
    .eraseToAnyPublisher()
  }
}
