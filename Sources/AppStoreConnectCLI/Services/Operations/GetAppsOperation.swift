// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetAppsOperation: APIOperation {
    struct GetAppsDependencies {
        let apps: (APIEndpoint<AppsResponse>) -> Future<AppsResponse, Error>
    }

    enum GetAppIdsError: LocalizedError {
        case couldntFindAnyAppsMatching(bundleIds: [String])
        case appsDoNotExist(bundleIds: [String])

        var errorDescription: String? {
            switch self {
            case .couldntFindAnyAppsMatching(let bundleIds):
                return "No apps were found matching \(bundleIds)"
            case .appsDoNotExist(let bundleIds):
                return "Specified apps were non found / do not exist: \(bundleIds)"
            }
        }
    }

    private let options: GetAppsOptions

    init(options: GetAppsOptions) {
        self.options = options
    }

    func execute(
        with dependencies: GetAppsDependencies
    ) -> AnyPublisher<[AppStoreConnect_Swift_SDK.App], Error> {
        let bundleIds = options.bundleIds
        let endpoint = APIEndpoint.apps(filters: [.bundleId(bundleIds)])

        return dependencies.apps(endpoint)
            .tryMap { (response: AppsResponse) throws -> [AppStoreConnect_Swift_SDK.App] in
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
