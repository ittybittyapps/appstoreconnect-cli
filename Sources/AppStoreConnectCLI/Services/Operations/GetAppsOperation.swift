// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetAppsOperation: APIOperation {

    struct Options {
        let bundleIds: [String]
    }

    enum GetAppIdsError: LocalizedError {
        case couldntFindAnyAppsMatching(bundleIds: [String])
        case appsDoNotExist(bundleIds: [String])

        var errorDescription: String? {
            switch self {
            case .couldntFindAnyAppsMatching(let bundleIds):
                return "No apps were found matching \(bundleIds)."
            case .appsDoNotExist(let bundleIds):
                return "Specified apps were non found / do not exist: \(bundleIds)."
            }
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    typealias App = AppStoreConnect_Swift_SDK.App

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[App], Error> {
        let bundleIds = options.bundleIds
        let endpoint = APIEndpoint.apps(filters: [.bundleId(bundleIds)])

        return requestor.request(endpoint)
            .tryMap { (response: AppsResponse) throws -> [App] in
                guard !response.data.isEmpty else {
                    throw GetAppIdsError.couldntFindAnyAppsMatching(bundleIds: bundleIds)
                }

                let responseBundleIds = Set(response.data.compactMap { $0.attributes?.bundleId })
                let bundleIds = Set(bundleIds)

                guard responseBundleIds == bundleIds else {
                    let nonExistentBundleIds = responseBundleIds.subtracting(bundleIds)
                    throw GetAppIdsError.appsDoNotExist(bundleIds: Array(nonExistentBundleIds))
                }

                return response.data
            }
            .eraseToAnyPublisher()
    }

}
