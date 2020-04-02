// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation

extension ListApps {
    static func getResourceIdsFrom(bundleIds: [String],
                                   by api: HTTPClient,
                                   completionHandler: @escaping (_ resourceIds: [String]) -> Void) {
        let getAppResourceIdRequest = APIEndpoint.apps(
            filters: [ListApps.Filter.bundleId(bundleIds)]
        )

        _ = api.request(getAppResourceIdRequest)
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { completionHandler($0.map { $0.id }) }
            )
    }
}
