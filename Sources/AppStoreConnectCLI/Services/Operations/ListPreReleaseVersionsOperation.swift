// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListPreReleaseVersionsOperation: APIOperation {

    struct ListPreReleaseVersionsDependencies {
        let users: (APIEndpoint<PreReleaseVersionsResponse>) -> Future<PreReleaseVersionsResponse, Error>
    }

    private let endpoint: APIEndpoint<UsersResponse>

    init(options: ListPreReleaseVersionsOptions) {
        endpoint = APIEndpoint.prereleaseVersions(
            
        )
    }
}
