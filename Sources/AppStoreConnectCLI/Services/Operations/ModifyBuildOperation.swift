// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBuildOperation: APIOperation {

  struct Options {
    let buildId: String?
    let expired: Bool?
    let usesNonExemptEncryption: Bool?
  }

  enum ModifyBuildError: LocalizedError {
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

  func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<BuildDetailsInfo, Error> {

    guard self.options.buildId != nil else {
      throw ModifyBuildError.noBuildIdFound
    }

    let buildModifyEndpoint = APIEndpoint.modify(
      buildWithId: self.options.buildId!,
      appEncryptionDeclarationId: "",
      expired: self.options.expired,
      usesNonExemptEncryption: self.options.usesNonExemptEncryption)

    return requestor.request(buildModifyEndpoint)
      .tryMap { (buildResponse) throws -> BuildDetailsInfo in

        guard (buildResponse.data.attributes != nil) else {
          throw ModifyBuildError.noBuildExist
        }

        return BuildDetailsInfo(buildResponse.data, nil)
    }
    .eraseToAnyPublisher()
  }
}
