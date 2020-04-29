// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListPreReleaseVersionsOperation: APIOperation {

    struct Options {

        enum Error: LocalizedError {
            case noMatchingBundleId([String])

            var errorDescription: String? {
                switch self {
                case .noMatchingBundleId(let bundleIds):
                    return "No app Bundle IDs found matching: \(bundleIds)"
                }
            }
        }

        var filterAppId: [String] = []
        var filterBundleId: [String] = []
        var filterVersion: [String] = []
        var filterPlatform: [Platform] = []
        var sort: ListPrereleaseVersions.Sort? = nil

        func filters(_ dependencies: Dependencies) throws -> [ListPrereleaseVersions.Filter] {
            
            var filter: [ListPrereleaseVersions.Filter] = []

            var filterAppId = self.filterAppId

            if filterBundleId.isEmpty == false {
                filterAppId = try dependencies
                    .apps(.apps(filters: [.bundleId(filterBundleId)]))
                    .map([App].init)
                    .await()
                    .map(\.id)

                if filterAppId.isEmpty {
                    throw Error.noMatchingBundleId(filterBundleId)
                }
            }

            if filterAppId.isEmpty == false {
                filter.append(.app(filterAppId))
            }

            if filterVersion.isEmpty == false {
                filter.append(.version(filterVersion))
            }

            if filterPlatform.isEmpty == false {
                filter.append(.platform(filterPlatform.map(\.rawValue)))
            }

            return filter
        }
    }

    struct Dependencies {
        let preReleaseVersions: (APIEndpoint<PreReleaseVersionsResponse>) -> Future<PreReleaseVersionsResponse, Error>
        let apps: (APIEndpoint<AppsResponse>) -> Future<AppsResponse, Error>
    }

    private func makeEndpoint(_ options: Options, dependencies: Dependencies) throws -> APIEndpoint<PreReleaseVersionsResponse> {
        // FIXME: Underlying SDK API doesn't expose limits correctly.
        return .prereleaseVersions(
            filter: try options.filters(dependencies),
            include: [.app],
            sort: options.sort.map { [$0] }
        )
    }

    var options: Options

    func execute(with dependencies: Dependencies) -> AnyPublisher<[PreReleaseVersion], Error> {
        do {
            return dependencies
                .preReleaseVersions(try makeEndpoint(options, dependencies: dependencies))
                .map([PreReleaseVersion].init)
                .eraseToAnyPublisher()
        } catch Options.Error.noMatchingBundleId {
            return Just([PreReleaseVersion]())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
