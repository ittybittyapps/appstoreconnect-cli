// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation

struct DisableBundleIdCapabilityOperation: APIOperationV2 {

    struct Options {
        let capabilityId: String
    }

    private let service: BagbutikService
    private let options: Options

    init(service: BagbutikService, options: Options) {
        self.service = service
        self.options = options
    }
    
    func execute() async throws {
        _ = try await service.request(.deleteBundleIdCapabilityV1(id: options.capabilityId))
    }

}
