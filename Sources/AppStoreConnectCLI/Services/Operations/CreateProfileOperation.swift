// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateProfileOperation: APIOperation {

    struct Options {
        let name: String
        let bundleId: String
        let profileType: ProfileType
        let certificateIds: [String]
        let deviceIds: [String]
    }

    private let endpoint: APIEndpoint<ProfileResponse>

    init(options: Options) {
        endpoint = APIEndpoint.create(
            profileWithId: options.bundleId,
            name: options.name,
            profileType: options.profileType,
            certificateIds: options.certificateIds,
            deviceIds: options.profileType.areDeviceIdsRequired ? options.deviceIds : []
        )
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Profile, Error> {
        requestor
            .request(endpoint)
            .map { $0.data }
            .eraseToAnyPublisher()
    }

}

fileprivate extension ProfileType {
    var areDeviceIdsRequired: Bool {
        return !self.rawValue.contains("_APP_STORE")
    }
}
