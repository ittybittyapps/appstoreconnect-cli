// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadPreReleaseVersionOperation: APIOperation {

    struct Options {
        var appId: String
    }

    enum ReadPreReleaseVersionError: LocalizedError {
        case noVersionExist
        case versionNotUnique

        var errorDescription: String? {
            switch self {
            case .noVersionExist:
                return "No prerelease version exists"
            case .versionNotUnique:
                return "More than 1 prerelease version returned"
            }
        }
    }

    typealias PreReleaseVersion =  AppStoreConnect_Swift_SDK.PrereleaseVersion
    typealias Relationships = [AppStoreConnect_Swift_SDK.PreReleaseVersionRelationship]?
    typealias Output = (preReleaseVersion: PreReleaseVersion, relationships: Relationships)


    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<Output, Swift.Error> {
        let endpoint = APIEndpoint.prereleaseVersion(
            withId: options.appId,
            include: [.app]
        )


        return requestor.request(endpoint)
            .tryMap { (prereleaseVersionResponse) throws -> Output in

                return (prereleaseVersionResponse.data, prereleaseVersionResponse.included)

            }
            .eraseToAnyPublisher()
    }
}
