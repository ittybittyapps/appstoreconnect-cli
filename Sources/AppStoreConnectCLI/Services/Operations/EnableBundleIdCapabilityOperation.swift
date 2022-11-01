// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation

struct EnableBundleIdCapabilityOperation: APIOperationV2 {

    struct Options {
        let bundleIdResourceId: String
        let capabilityType: CapabilityType
    }

    private let service: BagbutikService
    private let options: Options

    init(service: BagbutikService, options: Options) {
        self.service = service
        self.options = options
    }

    func execute() async throws -> BundleIdCapability {
        let body = BundleIdCapabilityCreateRequest(
            data: .init(
                attributes: .init(capabilityType: options.capabilityType),
                relationships: .init(bundleId: .init(data: .init(id: options.bundleIdResourceId)))
            )
        )
        
        return try await service.request(.createBundleIdCapabilityV1(requestBody: body)).data
    }

}
