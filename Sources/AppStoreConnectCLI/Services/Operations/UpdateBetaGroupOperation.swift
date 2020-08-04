// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct FileSystem.BetaGroup

struct UpdateBetaGroupOperation: APIOperation {

    struct Options {
        let betaGroup: BetaGroup
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<BetaGroupResponse, Error> {
        let betaGroup = options.betaGroup

        let endpoint = APIEndpoint.modify(
            betaGroupWithId: betaGroup.id!,
            name: betaGroup.groupName,
            publicLinkEnabled: betaGroup.publicLinkEnabled,
            publicLinkLimit: betaGroup.publicLinkLimit,
            publicLinkLimitEnabled: betaGroup.publicLinkLimitEnabled
        )

        return requestor.request(endpoint).eraseToAnyPublisher()
    }

}
