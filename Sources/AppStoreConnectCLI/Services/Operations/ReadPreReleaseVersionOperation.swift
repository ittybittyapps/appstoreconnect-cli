// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadPreReleaseVersionOperation: APIOperation {

    struct Options {
        var filterAppId: String
        var filterVersion: String
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
        var filters: [ListPrereleaseVersions.Filter] = []
        filters += options.filterAppId.isEmpty ? [] : [.app([options.filterAppId])]
        filters += options.filterVersion.isEmpty ? [] : [.version([options.filterVersion])]

        let endpoint = APIEndpoint.prereleaseVersions(
            filter: filters,
            include: [.app]
        )

        return requestor.request(endpoint)
            .tryMap { (response) throws -> Output in
                switch response.data.count {
                case 0:
                    throw ReadPreReleaseVersionError.noVersionExist
                case 1:
                    return Output(preReleaseVersion: response.data.first!, relationships: response.included)
                default:
                    throw ReadPreReleaseVersionError.versionNotUnique
                }
        }
        .eraseToAnyPublisher()
    }
}
