// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct CreateBetaGroupOperation: APIOperation {
    struct CreateBetaGroupDependencies {}

    init(options: CreateBetaGroupOptions) {}

    func execute(with dependencies: CreateBetaGroupDependencies) -> AnyPublisher<BetaGroup, Error> {
        Empty().eraseToAnyPublisher()
    }
}
